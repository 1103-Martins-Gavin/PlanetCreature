extends CanvasLayer

func transition_to_scene(path: String, tag: String):
	# 1. Fade to black
	$AnimationPlayer.play("fade_to_black")
	await $AnimationPlayer.animation_finished
	
	# 2. Update the Brain and load the new level secretly behind the black screen
	Inventory.target_spawn = tag
	get_tree().change_scene_to_file(path)
	
	# 3. Fade back to clear
	$AnimationPlayer.play("fade_to_normal")
