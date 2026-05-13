@tool
extends Resource
class_name StoryNode

@export var id: String = ""
@export_enum("scene", "dialogue", "choice", "condition", "event", "action", "jump", "end") var node_type: String = "scene"
@export var title: String = ""
@export_multiline var summary: String = ""

# Content group
@export_group("Content")
@export_multiline var text: String = ""
@export var speaker_id: String = ""

# Scene specific
@export_group("Scene Specific")
@export var scene_id: String = ""

# Logic & Branching
@export_group("Logic & Branching")
@export var condition: StoryCondition
@export var choices: Array[StoryChoice] = []
@export var effects: Array[StoryEffect] = []
@export var next_node_id: String = ""

# Editor Metadata
@export_group("Editor Meta")
@export var position: Vector2 = Vector2.ZERO
@export var editor_group_id: String = ""
@export var editor_color: String = ""
@export var editor_collapsed: bool = false
@export var source_block_ref: String = ""
