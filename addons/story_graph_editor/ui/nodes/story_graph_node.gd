@tool
extends GraphNode

var story_node_data: StoryNode

@onready var summary_label = $SummaryLabel

func setup(node_data: StoryNode) -> void:
	story_node_data = node_data
	name = node_data.id
	title = node_data.title
	
	update_summary()
	position_offset = node_data.position
	
	_apply_visual_style()
	_setup_ports()

func update_summary() -> void:
	if not summary_label: return
	
	if story_node_data.summary.is_empty():
		summary_label.text = story_node_data.text.substr(0, 50) + ("..." if story_node_data.text.length() > 50 else "")
	else:
		summary_label.text = story_node_data.summary

func _apply_visual_style() -> void:
	# Apply colors based on node_type as per design
	var header_color = Color(0.2, 0.2, 0.2, 1.0)
	
	match story_node_data.node_type:
		"scene":
			header_color = Color(0.18, 0.35, 0.58, 1.0) # 深蓝
		"dialogue":
			header_color = Color(0.15, 0.55, 0.55, 1.0) # 青色
		"choice":
			header_color = Color(0.45, 0.25, 0.55, 1.0) # 紫色
		"condition":
			header_color = Color(0.75, 0.45, 0.15, 1.0) # 橙色
		"event", "action":
			header_color = Color(0.25, 0.55, 0.35, 1.0) # 绿色
		"end":
			header_color = Color(0.15, 0.15, 0.15, 1.0) # 灰黑
			
	var stylebox = get_theme_stylebox("titlebar").duplicate()
	if stylebox is StyleBoxFlat:
		stylebox.bg_color = header_color
		stylebox.corner_radius_top_left = 6
		stylebox.corner_radius_top_right = 6
		stylebox.content_margin_left = 12
		stylebox.content_margin_right = 12
		stylebox.content_margin_top = 8
		stylebox.content_margin_bottom = 8
		add_theme_stylebox_override("titlebar", stylebox)
		
	var stylebox_selected = stylebox.duplicate()
	stylebox_selected.border_width_left = 2
	stylebox_selected.border_width_right = 2
	stylebox_selected.border_width_top = 2
	stylebox_selected.border_color = Color.WHITE
	add_theme_stylebox_override("titlebar_selected", stylebox_selected)
	
	var panel_style = get_theme_stylebox("panel").duplicate()
	if panel_style is StyleBoxFlat:
		panel_style.corner_radius_bottom_left = 6
		panel_style.corner_radius_bottom_right = 6
		panel_style.content_margin_left = 12
		panel_style.content_margin_right = 12
		panel_style.content_margin_bottom = 12
		add_theme_stylebox_override("panel", panel_style)
		
	var panel_selected = panel_style.duplicate()
	panel_selected.border_width_left = 2
	panel_selected.border_width_right = 2
	panel_selected.border_width_bottom = 2
	panel_selected.border_color = Color.WHITE
	add_theme_stylebox_override("panel_selected", panel_selected)

func _setup_ports() -> void:
	# Clear existing slots except the first one
	for i in range(1, get_child_count()):
		set_slot(i, false, 0, Color.WHITE, false, 0, Color.WHITE)
		get_child(i).queue_free()
		
	# Input port is always on slot 0 (left side)
	var has_input = story_node_data.node_type != "start"
	set_slot(0, has_input, 0, Color.WHITE, false, 0, Color.WHITE)
	
	# Output ports
	if story_node_data.node_type == "end":
		return # No output
		
	if story_node_data.choices.size() > 0:
		set_slot(0, has_input, 0, Color.WHITE, false, 0, Color.WHITE) # disable default output on slot 0
		
		for i in range(story_node_data.choices.size()):
			var choice = story_node_data.choices[i]
			var slot_idx = i + 1
			
			var choice_label = Label.new()
			choice_label.text = "▶ " + choice.text
			add_child(choice_label)
			
			set_slot(slot_idx, false, 0, Color.WHITE, true, 0, Color.WHITE)
	else:
		# Single output on slot 0
		set_slot(0, has_input, 0, Color.WHITE, true, 0, Color.WHITE)
