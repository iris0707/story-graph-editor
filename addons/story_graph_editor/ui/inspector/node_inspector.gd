@tool
extends VBoxContainer

@onready var header_label = $HeaderLabel
@onready var edit_id = $Scroll/ContentVBox/GroupBasic/Grid/EditID
@onready var option_type = $Scroll/ContentVBox/GroupBasic/Grid/OptionType
@onready var edit_title = $Scroll/ContentVBox/GroupBasic/Grid/EditTitle
@onready var edit_summary = $Scroll/ContentVBox/GroupContent/EditSummary
@onready var edit_text = $Scroll/ContentVBox/GroupContent/EditText

var current_node: StoryNode
var current_graph_node: GraphNode

func _ready() -> void:
	# Connect signals to update underlying data when UI changes
	if edit_id: edit_id.text_changed.connect(_on_id_changed)
	if edit_title: edit_title.text_changed.connect(_on_title_changed)
	if edit_summary: edit_summary.text_changed.connect(_on_summary_changed)
	if edit_text: edit_text.text_changed.connect(_on_text_changed)
	if option_type: option_type.item_selected.connect(_on_type_selected)
	
	clear_inspector()

func clear_inspector() -> void:
	current_node = null
	current_graph_node = null
	header_label.text = "未选中节点"
	edit_id.text = ""
	edit_title.text = ""
	edit_summary.text = ""
	edit_text.text = ""
	# disable inputs
	_set_inputs_disabled(true)

func _set_inputs_disabled(disabled: bool) -> void:
	edit_id.editable = !disabled
	edit_title.editable = !disabled
	edit_summary.editable = !disabled
	edit_text.editable = !disabled
	option_type.disabled = disabled

func inspect_node(story_node: StoryNode, graph_node: GraphNode) -> void:
	current_node = story_node
	current_graph_node = graph_node
	
	header_label.text = "正在编辑: " + story_node.title
	
	edit_id.text = story_node.id
	edit_title.text = story_node.title
	edit_summary.text = story_node.summary
	edit_text.text = story_node.text
	
	# Select correct type in dropdown
	for i in range(option_type.item_count):
		if option_type.get_item_text(i) == story_node.node_type:
			option_type.select(i)
			break
			
	_set_inputs_disabled(false)

# --- Data updating logic ---

func _on_id_changed(new_text: String) -> void:
	if current_node:
		current_node.id = new_text
		if current_graph_node:
			current_graph_node.name = new_text

func _on_title_changed(new_text: String) -> void:
	if current_node:
		current_node.title = new_text
		if current_graph_node:
			current_graph_node.title = new_text

func _on_summary_changed() -> void:
	if current_node:
		current_node.summary = edit_summary.text
		if current_graph_node and current_graph_node.has_method("update_summary"):
			current_graph_node.update_summary()

func _on_text_changed() -> void:
	if current_node:
		current_node.text = edit_text.text
		if current_node.summary.is_empty() and current_graph_node and current_graph_node.has_method("update_summary"):
			current_graph_node.update_summary()

func _on_type_selected(index: int) -> void:
	if current_node:
		current_node.node_type = option_type.get_item_text(index)
		if current_graph_node and current_graph_node.has_method("_apply_visual_style"):
			current_graph_node._apply_visual_style()
