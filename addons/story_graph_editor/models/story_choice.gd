@tool
extends Resource
class_name StoryChoice

@export var id: String = ""
@export var text: String = ""
@export var condition: StoryCondition
@export var effects: Array[StoryEffect] = []
@export var next_node_id: String = ""
