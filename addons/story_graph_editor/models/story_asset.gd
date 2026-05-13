@tool
extends Resource
class_name StoryAsset

@export var schema_version: String = "1.0.0"
@export var story_id: String = ""
@export var title: String = ""
@export_multiline var summary: String = ""
@export var entry_node_id: String = ""

@export_group("Data Arrays")
@export var nodes: Array[StoryNode] = []
@export var variables: Array[StoryVariable] = []
@export var characters: Array[StoryCharacter] = []
@export var scenes: Array[StorySceneDef] = []
# Edge arrays can be added here if separated from nodes, but per your schema suggestion:
# "运行时逻辑：选项可内嵌，编辑器显示：自动展开为边"
# so edges can be dynamically built from node choices and next_node_id.
