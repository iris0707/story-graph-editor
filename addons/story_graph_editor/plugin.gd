@tool
extends EditorPlugin

const MainViewScene = preload("res://addons/story_graph_editor/ui/story_graph_main_view.tscn")
var main_view_instance: Control

func _enter_tree() -> void:
	main_view_instance = MainViewScene.instantiate()
	# Add to the main editor screen
	EditorInterface.get_editor_main_screen().add_child(main_view_instance)
	_make_visible(false)
	print("Story Graph Editor plugin enabled.")

func _exit_tree() -> void:
	if main_view_instance:
		main_view_instance.queue_free()
	print("Story Graph Editor plugin disabled.")

func _has_main_screen() -> bool:
	return true

func _make_visible(visible: bool) -> void:
	if main_view_instance:
		main_view_instance.visible = visible

func _get_plugin_name() -> String:
	return "Story Graph"

func _get_plugin_icon() -> Texture2D:
	return EditorInterface.get_editor_theme().get_icon("GraphEdit", "EditorIcons")
