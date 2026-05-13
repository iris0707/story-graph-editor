@tool
extends Control

@onready var btn_new = $VBox/Toolbar/BtnNew
@onready var btn_import = $VBox/Toolbar/BtnImport
@onready var btn_layout = $VBox/Toolbar/BtnLayout
@onready var graph_edit = $"VBox/MainSplit/WorkspaceSplit/RightSplit/MainCanvas/Graph视图"
@onready var node_inspector = $VBox/MainSplit/WorkspaceSplit/RightSplit/InspectorPanel/NodeInspector
@onready var sidebar_tabs = $VBox/MainSplit/WorkspaceSplit/Sidebar
@onready var list_nodes = $"VBox/MainSplit/WorkspaceSplit/Sidebar/剧情图谱"
@onready var list_vars = $"VBox/MainSplit/WorkspaceSplit/Sidebar/变量"
@onready var list_chars = $"VBox/MainSplit/WorkspaceSplit/Sidebar/角色"
@onready var list_scenes = $"VBox/MainSplit/WorkspaceSplit/Sidebar/场景"

const StoryGraphNodeScene = preload("res://addons/story_graph_editor/ui/nodes/story_graph_node.tscn")
const StoryJsonImporter = preload("res://addons/story_graph_editor/importer/story_json_importer.gd")

var current_story_asset: StoryAsset
var file_dialog: EditorFileDialog

func _ready() -> void:
	if btn_new: btn_new.pressed.connect(_on_new_story_pressed)
	if btn_import: btn_import.pressed.connect(_on_import_pressed)
	if btn_layout: btn_layout.pressed.connect(_on_layout_pressed)
	
	if list_nodes: list_nodes.item_activated.connect(_on_node_list_item_activated)
	
	# FileDialog setup
	file_dialog = EditorFileDialog.new()
	file_dialog.file_mode = EditorFileDialog.FILE_MODE_OPEN_FILE
	file_dialog.access = EditorFileDialog.ACCESS_FILESYSTEM
	file_dialog.add_filter("*.json", "JSON Files")
	file_dialog.file_selected.connect(_on_file_selected)
	add_child(file_dialog)
	
	# GraphEdit setup
	if graph_edit:
		graph_edit.connection_request.connect(_on_graph_connection_request)
		graph_edit.disconnection_request.connect(_on_graph_disconnection_request)
		graph_edit.node_selected.connect(_on_graph_node_selected)
		graph_edit.node_deselected.connect(_on_graph_node_deselected)
		
		# Add a context menu connection
		graph_edit.popup_request.connect(_on_graph_popup_request)

func _on_new_story_pressed() -> void:
	print("Story Graph: New Story created. Spawning test nodes.")
	_spawn_test_nodes()

func _on_import_pressed() -> void:
	print("Story Graph: Import dialog opened.")
	file_dialog.popup_file_dialog()

func _on_layout_pressed() -> void:
	if not current_story_asset: return
	_auto_layout_graph()

func _on_node_list_item_activated(index: int) -> void:
	var node_id = list_nodes.get_item_text(index)
	for child in graph_edit.get_children():
		if child is GraphNode and child.name == node_id:
			graph_edit.set_selected(child)
			# Center view on node
			graph_edit.scroll_offset = child.position_offset - graph_edit.size / 2.0 + child.size / 2.0
			break

func _on_file_selected(path: String) -> void:
	print("Story Graph: Selected file for import: ", path)
	var file = FileAccess.open(path, FileAccess.READ)
	if file:
		var json_text = file.get_as_text()
		file.close()
		
		# Strip BOM if present
		if json_text.begins_with("\ufeff"):
			json_text = json_text.substr(1)
			
		print("Story Graph: Successfully read file. Content length: ", json_text.length())
		_run_json_import(json_text)
	else:
		var err = FileAccess.get_open_error()
		push_error("Story Graph: Failed to open file: " + path + " (Error code: " + str(err) + ")")

func _run_json_import(json_text: String) -> void:
	print("Story Graph: Starting JSON parsing...")
	current_story_asset = StoryJsonImporter.parse_json_to_asset(json_text)
	
	if current_story_asset:
		print("Story Graph: Successfully imported story: ", current_story_asset.title)
		print("Story Graph: Loaded ", current_story_asset.nodes.size(), " nodes into current_story_asset.")
		if $VBox/Toolbar/StatusLabel:
			$VBox/Toolbar/StatusLabel.text = "当前故事: " + current_story_asset.title
		_render_story_asset()
		_update_sidebar_lists()
		# _auto_layout_graph() # Don't auto-layout on import to respect JSON positions
	else:
		push_error("Story Graph: Failed to parse JSON into StoryAsset")

func _update_sidebar_lists() -> void:
	if not current_story_asset: return
	
	if list_nodes:
		list_nodes.clear()
		for node in current_story_asset.nodes:
			list_nodes.add_item(node.id)
			
	if list_vars:
		list_vars.clear()
		for v in current_story_asset.variables:
			list_vars.add_item(v.id + " (" + v.data_type + ")")
			
	if list_chars:
		list_chars.clear()
		for c in current_story_asset.characters:
			list_chars.add_item(c.name)
			
	if list_scenes:
		list_scenes.clear()
		for s in current_story_asset.scenes:
			list_scenes.add_item(s.name)

func _auto_layout_graph() -> void:
	if not current_story_asset or current_story_asset.nodes.is_empty(): return
	
	# Very basic topological sort / level assignment for layout
	var levels = {} # node_id -> level
	var node_dict = {}
	
	for node in current_story_asset.nodes:
		node_dict[node.id] = node
		levels[node.id] = 0
		
	# Find entry node
	var entry_id = current_story_asset.entry_node_id
	if entry_id == "" and current_story_asset.nodes.size() > 0:
		entry_id = current_story_asset.nodes[0].id
		
	# BFS to assign levels
	var queue = [entry_id]
	var visited = {entry_id: true}
	
	while not queue.is_empty():
		var curr_id = queue.pop_front()
		var curr_level = levels[curr_id]
		var node = node_dict.get(curr_id)
		
		if not node: continue
		
		var children = []
		if node.next_node_id != "": children.append(node.next_node_id)
		for choice in node.choices:
			if choice.next_node_id != "": children.append(choice.next_node_id)
			
		for child_id in children:
			levels[child_id] = max(levels.get(child_id, 0), curr_level + 1)
			if not visited.has(child_id):
				visited[child_id] = true
				queue.append(child_id)
				
	# Assign positions based on levels
	var level_counts = {}
	var horizontal_spacing = 350
	var vertical_spacing = 200
	
	for child in graph_edit.get_children():
		if child is GraphNode:
			var lvl = levels.get(child.name, 0)
			var count = level_counts.get(lvl, 0)
			
			child.position_offset = Vector2(lvl * horizontal_spacing, count * vertical_spacing)
			
			level_counts[lvl] = count + 1

func _render_story_asset() -> void:
	if not current_story_asset: return
	print("Story Graph: Rendering story asset to GraphEdit...")
	
	graph_edit.clear_connections()
	for child in graph_edit.get_children():
		if child is GraphNode:
			child.queue_free()
			
	if node_inspector:
		node_inspector.clear_inspector()
			
	# 1. Instantiate all nodes
	var node_ui_map = {} # Maps story_node.id to GraphNode instance name
	
	print("Story Graph: Spawning UI nodes...")
	for story_node in current_story_asset.nodes:
		var ui_node = StoryGraphNodeScene.instantiate()
		graph_edit.add_child(ui_node)
		ui_node.setup(story_node)
		node_ui_map[story_node.id] = ui_node.name
		print("Story Graph: Spawned node '", story_node.id, "' as '", ui_node.name, "'")
		
	# 2. Connect nodes visually based on choices and next_node_id
	call_deferred("_connect_imported_nodes", node_ui_map)

func _connect_imported_nodes(node_ui_map: Dictionary) -> void:
	print("Story Graph: Connecting UI nodes...")
	var connection_count = 0
	for story_node in current_story_asset.nodes:
		var from_ui_name = node_ui_map.get(story_node.id, "")
		if from_ui_name == "": continue
		
		# Connect direct next_node_id (if no choices, it uses slot 0)
		if story_node.choices.is_empty() and story_node.next_node_id != "":
			var to_ui_name = node_ui_map.get(story_node.next_node_id, "")
			if to_ui_name != "":
				graph_edit.connect_node(from_ui_name, 0, to_ui_name, 0)
				connection_count += 1
				
		# Connect choices (slots 1, 2, 3...)
		elif not story_node.choices.is_empty():
			for i in range(story_node.choices.size()):
				var choice = story_node.choices[i]
				if choice.next_node_id != "":
					var to_ui_name = node_ui_map.get(choice.next_node_id, "")
					if to_ui_name != "":
						# In Godot 4, port indices are 0-based among ENABLED ports.
						# Since slot 0 output is disabled when choices exist, slot 1 is port 0, slot 2 is port 1, etc.
						var from_port = i 
						graph_edit.connect_node(from_ui_name, from_port, to_ui_name, 0)
						connection_count += 1
	print("Story Graph: Successfully established ", connection_count, " visual connections.")

func _on_graph_connection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	graph_edit.connect_node(from_node, from_port, to_node, to_port)

func _on_graph_disconnection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	graph_edit.disconnect_node(from_node, from_port, to_node, to_port)

func _on_graph_popup_request(position: Vector2) -> void:
	# TODO: Show right-click menu to add nodes
	print("Right click at ", position)

func _on_graph_node_selected(node: Node) -> void:
	if node is GraphNode and node.has_method("setup") and node_inspector:
		node_inspector.inspect_node(node.story_node_data, node)

func _on_graph_node_deselected(node: Node) -> void:
	# If no nodes are selected, clear inspector
	var selected_nodes = []
	for child in graph_edit.get_children():
		if child is GraphNode and child.selected:
			selected_nodes.append(child)
			
	if selected_nodes.is_empty() and node_inspector:
		node_inspector.clear_inspector()

func _spawn_test_nodes() -> void:
	graph_edit.clear_connections()
	for child in graph_edit.get_children():
		if child is GraphNode:
			child.queue_free()
			
	# Create a Scene Node
	var scene_node = StoryNode.new()
	scene_node.id = "scene_awake"
	scene_node.node_type = "scene"
	scene_node.title = "客房醒来"
	scene_node.text = "你在陌生的客房中醒来，门被锁住。"
	scene_node.position = Vector2(100, 100)
	
	# Create Choice 1
	var choice1 = StoryChoice.new()
	choice1.id = "c1"
	choice1.text = "检查房门"
	choice1.next_node_id = "event_door"
	
	# Create Choice 2
	var choice2 = StoryChoice.new()
	choice2.id = "c2"
	choice2.text = "检查镜框"
	choice2.next_node_id = "event_key"
	
	scene_node.choices = [choice1, choice2]
	
	# Create Event Node (Door)
	var event_door = StoryNode.new()
	event_door.id = "event_door"
	event_door.node_type = "event"
	event_door.title = "门被锁住"
	event_door.text = "门锁得很死，徒手无法打开。"
	event_door.position = Vector2(450, 50)
	
	# Create Event Node (Key)
	var event_key = StoryNode.new()
	event_key.id = "event_key"
	event_key.node_type = "event"
	event_key.title = "发现钥匙"
	event_key.text = "你在镜框后摸到一把小钥匙。"
	event_key.position = Vector2(450, 250)
	
	# Instantiate and add to graph
	var ui_scene = StoryGraphNodeScene.instantiate()
	graph_edit.add_child(ui_scene)
	ui_scene.setup(scene_node)
	
	var ui_door = StoryGraphNodeScene.instantiate()
	graph_edit.add_child(ui_door)
	ui_door.setup(event_door)
	
	var ui_key = StoryGraphNodeScene.instantiate()
	graph_edit.add_child(ui_key)
	ui_key.setup(event_key)
	
	# Connect nodes visually
	# Scene port 0 goes to Door (choice 1)
	# Scene port 1 goes to Key (choice 2)
	call_deferred("_connect_test_nodes")

func _connect_test_nodes() -> void:
	graph_edit.connect_node("scene_awake", 0, "event_door", 0)
	graph_edit.connect_node("scene_awake", 1, "event_key", 0)
