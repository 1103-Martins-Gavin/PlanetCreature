extends StaticBody2D
class_name BaseResourceNode

@export var max_health: int = 3
@export var drop_table: Array[PackedScene] 

var current_health: int
var original_scale: Vector2 # <--- We need a place to save the starting size!

func _ready():
	current_health = max_health
	# Memorize the exact size you made it in the editor!
	original_scale = $Sprite2D.scale

func take_damage(amount: int):
	current_health -= amount
	
	# Squish it relative to its original size, then bounce back to original size!
	var tween = create_tween()
	tween.tween_property($Sprite2D, "scale", original_scale * Vector2(1.1, 0.9), 0.05)
	tween.tween_property($Sprite2D, "scale", original_scale, 0.1)
	
	if current_health <= 0:
		die()

func die():
	for item in drop_table:
		var loot = item.instantiate()
		loot.global_position = global_position
		get_parent().add_child(loot)
		
		# If the item has real physics (RigidBody2D), launch it!
		if loot is RigidBody2D:
			# randf_range gives it a random X direction (left/right) 
			# and a strong negative Y (which shoots it up into the air!)
			loot.linear_velocity = Vector2(randf_range(-150, 150), randf_range(-300, -150))
			
	queue_free()
