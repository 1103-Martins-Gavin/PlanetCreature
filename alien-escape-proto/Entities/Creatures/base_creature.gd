extends CharacterBody2D
class_name BaseCreature

# --- 1. BEHAVIOR TYPES ---
# This creates a dropdown in the Inspector!
enum Disposition {PASSIVE, NEUTRAL, HOSTILE}
@export var behavior: Disposition = Disposition.HOSTILE

# --- 2. STATS ---
@export var max_health: int = 3
@export var move_speed: float = 100.0

# --- 3. COMBAT ---
@export var attack_damage: int = 1
# If true, it shoots projectiles. If false, it uses melee bites!
@export var is_ranged: bool = false 

# --- 4. LOOT TABLE ---
# An array that can hold multiple Custom Resources or Scenes to drop when it dies!
@export var drop_table: Array[PackedScene]

# --- THE INTERNAL BRAIN ---
enum State {IDLE, WANDER, FLEE, CHASE, ATTACK}
var current_state: State = State.IDLE
var target_player = null
var current_health: int

func _ready():
	current_health = max_health

func _physics_process(delta):
	# Add gravity
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	# The State Machine: What should I be doing right now?
	match current_state:
		State.IDLE:
			# Friction: slow down to a stop
			velocity.x = move_toward(velocity.x, 0, move_speed)
			
		State.WANDER:
			pass # We will add random timer logic for this later!
			
		State.CHASE:
			if target_player != null:
				# Math trick: sign() returns 1 if positive (right), -1 if negative (left)
				var direction = sign(target_player.global_position.x - global_position.x)
				velocity.x = direction * move_speed
				
				# Flip the sprite to face the player!
				if direction != 0:
					$Sprite2D.scale.x = direction
					
		State.FLEE:
			if target_player != null:
				# Reverse the math: Run AWAY from the player
				var direction = sign(global_position.x - target_player.global_position.x)
				velocity.x = direction * move_speed
				
				if direction != 0:
					$Sprite2D.scale.x = direction

	move_and_slide()

# --- HOW IT TAKES DAMAGE ---
func take_damage(amount: int):
	current_health -= amount
	
	# If I am Neutral and I get hit, I become Hostile!
	if behavior == Disposition.NEUTRAL:
		behavior = Disposition.HOSTILE
		current_state = State.CHASE
		
	# If I am Passive and I get hit, I run away!
	elif behavior == Disposition.PASSIVE:
		current_state = State.FLEE
		
	if current_health <= 0:
		die()

func die():
	# Loop through the drop table and spawn all the loot!
	for item in drop_table:
		var loot = item.instantiate()
		loot.global_position = global_position
		get_parent().add_child(loot)
	queue_free()


func _on_detection_zone_body_entered(body):
	if body.name == "Player":
		target_player = body
		
		# Hostile mobs instantly attack!
		if behavior == Disposition.HOSTILE:
			current_state = State.CHASE
			
		# Notice we completely deleted the PASSIVE flee check here!
		# Because we deleted it, they will just sit in State.IDLE until 
		# your take_damage() function forcefully switches them to State.FLEE.

func _on_detection_zone_body_exited(body):
	if body.name == "Player":
		target_player = null
		# When the player is gone, go back to chilling
		current_state = State.IDLE
