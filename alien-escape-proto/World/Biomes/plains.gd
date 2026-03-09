extends Node2D

func _ready():
	# This magically searches the entire level for a node with the exact name stored in memory
	var spawn_node = find_child(Inventory.target_spawn, true, false)
	
	if spawn_node != null:
		# Instantly teleport the player to that crosshair!
		$Player.global_position = spawn_node.global_position
		
		# THE FIX: Tell the player to memorize this exact spot for when they die!
		$Player.active_spawn_point = spawn_node.global_position
		
	else:
		print("CRITICAL ERROR: Could not find a Spawn Marker named: ", Inventory.target_spawn)
		
		# FAILSAFE: If you just hit Play Scene (F6) to test, tell the player to just memorize where you placed them in the editor.
		if has_node("Player"):
			$Player.active_spawn_point = $Player.global_position
