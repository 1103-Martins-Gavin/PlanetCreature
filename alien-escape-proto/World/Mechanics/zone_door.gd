extends Area2D

@export_file("*.tscn") var next_scene_path: String
# This lets us name the specific door in the Inspector!
@export var spawn_tag: String = "LeftDoor"

func _on_body_entered(body):
	if body.name == "Player":
		if next_scene_path != "": 
			# Tell our new Autoload to handle the entire sequence!
			TransitionScreen.transition_to_scene(next_scene_path, spawn_tag)
		else:
			print("Error: You forgot to tell this door where to go!")
