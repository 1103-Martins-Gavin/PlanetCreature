extends Area2D

@export_file("*.tscn") var next_scene_path: String
@export var spawn_tag: String = "LeftDoor"

func _on_body_entered(body):
	if body.name == "Player":
		# Just trigger your custom Autoload function and let it do all the heavy lifting!
		TransitionScreen.transition_to_scene(next_scene_path, spawn_tag)
