@tool
extends Resource
class_name StorySceneDef

@export var id: String = ""
@export var name: String = ""
@export_multiline var description: String = ""
@export var background_ref: String = ""
@export var tags: Array[String] = []
@export var interactables: Array[String] = []
@export var connected_scene_ids: Array[String] = []
