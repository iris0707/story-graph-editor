@tool
extends Resource
class_name StoryCondition

@export_enum("expr", "all", "any", "not", "variable_compare", "flag_true", "item_owned", "clue_owned") var type: String = "expr"

# For expr type
@export_multiline var expr: String = ""

# For structured conditions (variable_compare, etc.)
@export var variable: String = ""
@export_enum("==", "!=", ">", ">=", "<", "<=") var operator: String = "=="
@export var value: Variant

@export var item_id: String = ""
@export var clue_id: String = ""

# For all/any/not
@export var sub_conditions: Array[StoryCondition] = []
