extends Area2D

func _ready():
	# Start the jump animation the moment this node spawns
	var tween = create_tween()
	var random_x = randf_range(-40, 40)
	
	# Calculate the math relative to wherever it spawned
	var jump_peak = position + Vector2(random_x, -50)
	var floor_land = position + Vector2(random_x, 15) 
	
	tween.tween_property(self, "position", jump_peak, 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "position", floor_land, 0.2).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		Inventory.copper += 1
		queue_free()
