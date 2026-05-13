@tool
extends Resource
class_name StoryVariable

@export var id: String = ""
@export var name: String = ""
@export_enum("bool", "int", "float", "string", "enum") var data_type: String = "int"
@export var default_value: Variant = 0
@export_multiline var description: String = ""

@export_group("Editor Meta")
@export var category: String = ""
