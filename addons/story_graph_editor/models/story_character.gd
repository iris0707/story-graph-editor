@tool
extends Resource
class_name StoryCharacter

@export var id: String = ""
@export var name: String = ""
@export var title: String = ""
@export_multiline var description: String = ""
@export var portrait: String = ""
@export var tags: Array[String] = []

@export var default_location: String = ""
@export var variables: Array[String] = []
@export var topics: Array[String] = []
