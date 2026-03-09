extends Resource
class_name ToolData

@export var tool_name: String = "Basic Tool"
@export var tool_tier: int = 1
@export var damage: int = 1
@export var weapon_scene: PackedScene

# Future-proofing: We can easily add a dictionary or array here later 
# like '@export var crafting_ingredients: Array' when you are ready!
