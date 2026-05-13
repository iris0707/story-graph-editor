@tool
extends Resource
class_name StoryEffect

@export_enum("set_variable", "add_variable", "add_item", "remove_item", "gain_clue", "lose_clue", "change_scene", "unlock_node", "modify_relation", "update_quest_state") var type: String = "set_variable"

@export var variable: String = ""
@export var value: Variant

@export var item_id: String = ""
@export var quantity: int = 1

@export var clue_id: String = ""
@export var scene_id: String = ""
@export var node_id: String = ""
@export var character_id: String = ""
@export var quest_id: String = ""
@export var state: String = ""
@export var delta: int = 0
