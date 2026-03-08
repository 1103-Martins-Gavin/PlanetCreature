extends StaticBody2D

@export var drop_scene: PackedScene
@export var health: int = 3 
var active_player = null

func _ready():
	if name in Inventory.destroyed_objects:
		queue_free()

func _process(_delta):
	# 1. Is the player standing near me, and did they just click?
	if active_player != null and Input.is_action_just_pressed("mine"):
		
		# 2. Look directly at the Player's variables!
		var tool = active_player.equipped_tool
		var is_drawn = active_player.get_node("Pivot").visible
		
		# 3. If they are holding a valid tool, take damage!
		if tool != null and is_drawn and tool.tool_tier >= 1:
			
			# We use the dynamic DAMAGE stat from your Custom Resource!
			health -= tool.damage 
			print("Whack! Boulder took ", tool.damage, " damage. Health left: ", health)
			
			var tween = create_tween()
			tween.tween_property(self, "scale", Vector2(1.2, 0.8), 0.05)
			tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)
			
			if health <= 0:
				break_rock()

func _on_interact_zone_body_entered(body):
	if body.name == "Player":
		# Save a direct connection to the player!
		active_player = body 

func _on_interact_zone_body_exited(body):
	if body.name == "Player":
		# Break the connection when they walk away
		active_player = null 

func break_rock():
	for i in range(3):
		var loot = drop_scene.instantiate()
		loot.global_position = global_position 
		get_parent().add_child(loot)
	
	Inventory.destroyed_objects.append(name)
	queue_free()
