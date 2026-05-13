@tool
extends RefCounted
class_name StoryJsonImporter

## Parses a JSON string conforming to the Canonical Story Model Schema
## and returns a populated StoryAsset resource.
static func parse_json_to_asset(json_text: String) -> StoryAsset:
	print("Story Graph Importer: Starting JSON parse...")
	var json = JSON.new()
	var error = json.parse(json_text)
	
	if error != OK:
		push_error("Story Graph Importer: JSON Parse Error: ", json.get_error_message(), " at line ", json.get_error_line())
		return null
		
	var data = json.get_data()
	if typeof(data) != TYPE_DICTIONARY:
		push_error("Story Graph Importer: Root JSON must be an object. Got type: ", typeof(data))
		return null
		
	print("Story Graph Importer: Successfully parsed JSON into dictionary. Beginning to construct StoryAsset...")
	
	var asset = StoryAsset.new()
	
	# 1. Parse top-level metadata
	asset.schema_version = data.get("schema_version", "1.0.0")
	asset.story_id = data.get("story_id", "")
	asset.title = data.get("title", "")
	asset.summary = data.get("summary", "")
	asset.entry_node_id = data.get("entry_node_id", "")
	
	# 2. Parse basic arrays
	if data.has("variables") and typeof(data["variables"]) == TYPE_ARRAY:
		asset.variables = _parse_variables(data["variables"])
		print("Story Graph Importer: Parsed variables: ", asset.variables.size())
		
	if data.has("characters") and typeof(data["characters"]) == TYPE_ARRAY:
		asset.characters = _parse_characters(data["characters"])
		print("Story Graph Importer: Parsed characters: ", asset.characters.size())
		
	if data.has("scenes") and typeof(data["scenes"]) == TYPE_ARRAY:
		asset.scenes = _parse_scenes(data["scenes"])
		print("Story Graph Importer: Parsed scenes: ", asset.scenes.size())
		
	# 3. Parse Nodes (Core Logic)
	if data.has("nodes") and typeof(data["nodes"]) == TYPE_ARRAY:
		print("Story Graph Importer: Starting to parse nodes array...")
		asset.nodes = _parse_nodes(data["nodes"])
		print("Story Graph Importer: Parsed nodes: ", asset.nodes.size())
	else:
		push_warning("Story Graph Importer: No nodes found in JSON or nodes is not an array.")
		
	print("Story Graph Importer: StoryAsset construction complete.")
	return asset

static func _parse_variables(var_array: Array) -> Array[StoryVariable]:
	var result: Array[StoryVariable] = []
	for v_data in var_array:
		if typeof(v_data) != TYPE_DICTIONARY: continue
		
		var variable = StoryVariable.new()
		variable.id = v_data.get("id", "")
		variable.name = v_data.get("name", "")
		variable.data_type = v_data.get("data_type", "int")
		variable.default_value = v_data.get("default_value", 0)
		variable.description = v_data.get("description", "")
		result.append(variable)
	return result

static func _parse_characters(char_array: Array) -> Array[StoryCharacter]:
	var result: Array[StoryCharacter] = []
	for c_data in char_array:
		if typeof(c_data) != TYPE_DICTIONARY: continue
		
		var character = StoryCharacter.new()
		character.id = c_data.get("id", "")
		character.name = c_data.get("name", "")
		character.title = c_data.get("title", "")
		character.description = c_data.get("description", "")
		result.append(character)
	return result

static func _parse_scenes(scene_array: Array) -> Array[StorySceneDef]:
	var result: Array[StorySceneDef] = []
	for s_data in scene_array:
		if typeof(s_data) != TYPE_DICTIONARY: continue
		
		var scene = StorySceneDef.new()
		scene.id = s_data.get("id", "")
		scene.name = s_data.get("name", "")
		scene.description = s_data.get("description", "")
		result.append(scene)
	return result

static func _parse_nodes(node_array: Array) -> Array[StoryNode]:
	var result: Array[StoryNode] = []
	var y_offset = 50
	
	for n_data in node_array:
		if typeof(n_data) != TYPE_DICTIONARY: continue
		
		var node = StoryNode.new()
		node.id = n_data.get("id", "")
		node.node_type = n_data.get("node_type", "scene")
		node.title = n_data.get("title", "")
		node.summary = n_data.get("summary", "")
		
		# Auto layout fallback if position not provided in json
		if n_data.has("position") and typeof(n_data["position"]) == TYPE_DICTIONARY:
			node.position = Vector2(n_data["position"].get("x", 0), n_data["position"].get("y", 0))
		else:
			node.position = Vector2(200, y_offset)
			y_offset += 150
		
		# Parse content block
		if n_data.has("content") and typeof(n_data["content"]) == TYPE_DICTIONARY:
			var content = n_data["content"]
			node.text = content.get("text", "")
			node.speaker_id = content.get("speaker_id", "")
			
		node.scene_id = n_data.get("scene_id", "")
		node.next_node_id = n_data.get("next_node_id", "")
		
		# Parse Condition
		if n_data.has("condition") and typeof(n_data["condition"]) == TYPE_DICTIONARY:
			node.condition = _parse_condition(n_data["condition"])
			
		# Parse Effects
		if n_data.has("effects") and typeof(n_data["effects"]) == TYPE_ARRAY:
			node.effects = _parse_effects(n_data["effects"])
			
		# Parse Choices
		if n_data.has("choices") and typeof(n_data["choices"]) == TYPE_ARRAY:
			var choices: Array[StoryChoice] = []
			for c_data in n_data["choices"]:
				if typeof(c_data) != TYPE_DICTIONARY: continue
				
				var choice = StoryChoice.new()
				choice.id = c_data.get("id", "")
				choice.text = c_data.get("text", "")
				choice.next_node_id = c_data.get("next_node_id", "")
				
				if c_data.has("condition") and typeof(c_data["condition"]) == TYPE_DICTIONARY:
					choice.condition = _parse_condition(c_data["condition"])
					
				if c_data.has("effects") and typeof(c_data["effects"]) == TYPE_ARRAY:
					choice.effects = _parse_effects(c_data["effects"])
					
				choices.append(choice)
			node.choices = choices
			
		result.append(node)
	return result

static func _parse_condition(c_data: Dictionary) -> StoryCondition:
	var condition = StoryCondition.new()
	var type_str = c_data.get("type", "expr")
	
	if type_str == "expr":
		condition.type = "expr"
		condition.expr = c_data.get("expr", "")
	elif type_str == "item_owned":
		condition.type = "item_owned"
		condition.item_id = c_data.get("item_id", "")
	elif type_str == "clue_owned":
		condition.type = "clue_owned"
		condition.clue_id = c_data.get("clue_id", "")
	elif type_str == "all" or type_str == "any" or type_str == "not":
		condition.type = type_str
		if c_data.has("conditions") and typeof(c_data["conditions"]) == TYPE_ARRAY:
			var subs: Array[StoryCondition] = []
			for sub_data in c_data["conditions"]:
				if typeof(sub_data) == TYPE_DICTIONARY:
					subs.append(_parse_condition(sub_data))
			condition.sub_conditions = subs
	
	# Note: Expand other types as needed
	return condition

static func _parse_effects(effect_array: Array) -> Array[StoryEffect]:
	var result: Array[StoryEffect] = []
	for e_data in effect_array:
		if typeof(e_data) != TYPE_DICTIONARY: continue
		
		var effect = StoryEffect.new()
		effect.type = e_data.get("type", "set_variable")
		effect.variable = e_data.get("variable", "")
		effect.value = e_data.get("value", null)
		effect.item_id = e_data.get("item_id", "")
		effect.quantity = e_data.get("quantity", 1)
		effect.clue_id = e_data.get("clue_id", "")
		effect.scene_id = e_data.get("scene_id", "")
		effect.quest_id = e_data.get("quest_id", "")
		effect.state = e_data.get("state", "")
		
		result.append(effect)
	return result
