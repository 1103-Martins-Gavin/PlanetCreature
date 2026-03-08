extends Area2D

@export var creature_scene: PackedScene # Drag your Hare or Sporling in here!
@export var max_creatures: int = 3      # Never exceed this amount
@export var spawn_interval: float = 5.0 # Try to spawn one every 5 seconds

var current_creatures: int = 0

func _ready():
	# Setup the timer based on your Inspector settings
	$Timer.wait_time = spawn_interval
	$Timer.start()

# Make sure you connect the Timer's "timeout" signal to this function!
func _on_timer_timeout():
	if current_creatures < max_creatures and creature_scene != null:
		spawn_creature()

func spawn_creature():
	# 1. Get the exact size of your CollisionShape rectangle
	var spawn_area = $CollisionShape2D.shape.size
	var origin = $CollisionShape2D.global_position
	
	# 2. Pick a random X and Y coordinate inside that box
	var random_x = origin.x + randf_range(-spawn_area.x / 2, spawn_area.x / 2)
	var random_y = origin.y + randf_range(-spawn_area.y / 2, spawn_area.y / 2)
	
	# 3. Build the creature!
	var creature = creature_scene.instantiate()
	creature.global_position = Vector2(random_x, random_y)
	
	# 4. A brilliant Godot trick: Tell the spawner to listen for when the creature dies
	# so it can subtract 1 from the population counter!
	creature.tree_exited.connect(_on_creature_died)
	
	# 5. Add it to the world
	get_parent().add_child(creature)
	current_creatures += 1

func _on_creature_died():
	current_creatures -= 1
