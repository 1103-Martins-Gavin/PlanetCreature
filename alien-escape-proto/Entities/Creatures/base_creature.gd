extends CharacterBody2D
class_name BaseCreature

# --- 1. BEHAVIOR TYPES ---
enum Disposition {PASSIVE, NEUTRAL, HOSTILE}
@export var behavior: Disposition = Disposition.HOSTILE

# --- 2. STATS ---
@export var max_health: int = 3
@export var move_speed: float = 100.0

# --- 3. COMBAT ---
@export var attack_damage: int = 1
@export var is_ranged: bool = false 

# THE MISSING VARIABLES: Windup and cooldown timers!
@export var attack_windup: float = 0.5
@export var attack_cooldown: float = 1.5
var can_attack: bool = true
var player_in_attack_range: bool = false

# --- 4. LOOT TABLE ---
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
			velocity.x = move_toward(velocity.x, 0, move_speed)
		State.WANDER:
			pass 
		State.CHASE:
			if target_player != null:
				var direction = sign(target_player.global_position.x - global_position.x)
				velocity.x = direction * move_speed
				
				if direction != 0:
					$Sprite2D.scale.x = direction
		State.FLEE:
			if target_player != null:
				var direction = sign(global_position.x - target_player.global_position.x)
				velocity.x = direction * move_speed
				
				if direction != 0:
					$Sprite2D.scale.x = direction
					
		# THE MISSING LOGIC: How to actually bite the player!
		State.ATTACK:
			velocity.x = move_toward(velocity.x, 0, move_speed)
			if can_attack and player_in_attack_range and target_player != null:
				can_attack = false
				print("Creature winding up attack...")
				
				await get_tree().create_timer(attack_windup).timeout
				
				if player_in_attack_range and target_player != null:
					print("Creature strikes!")
					target_player.take_damage(attack_damage)
					
				await get_tree().create_timer(attack_cooldown).timeout
				can_attack = true

	move_and_slide()

# --- HOW IT TAKES DAMAGE ---
func take_damage(amount: int):
	current_health -= amount
	
	# Add a little squish effect so you feel the impact!
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.2, 0.8), 0.05)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)
	
	if behavior == Disposition.NEUTRAL:
		behavior = Disposition.HOSTILE
		current_state = State.CHASE
	elif behavior == Disposition.PASSIVE:
		current_state = State.FLEE
		
	if current_health <= 0:
		die()

func die():
	for item in drop_table:
		var loot = item.instantiate()
		loot.global_position = global_position
		get_parent().add_child(loot)
	queue_free()

# --- SENSORS ---
func _on_detection_zone_body_entered(body):
	if body.name == "Player":
		target_player = body
		if behavior == Disposition.HOSTILE:
			current_state = State.CHASE

func _on_detection_zone_body_exited(body):
	if body.name == "Player":
		target_player = null
		current_state = State.IDLE

# THE MISSING SENSORS: Telling the brain when to bite!
func _on_attack_zone_body_entered(body):
	if body.name == "Player":
		player_in_attack_range = true
		if behavior == Disposition.HOSTILE:
			current_state = State.ATTACK

func _on_attack_zone_body_exited(body):
	if body.name == "Player":
		player_in_attack_range = false
		if behavior == Disposition.HOSTILE:
			current_state = State.CHASE
