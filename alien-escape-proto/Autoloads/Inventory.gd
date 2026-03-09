extends Node
@export var max_health: float = 200.0
var current_health: float = 200.0

# --- REGEN VARIABLES ---
var time_since_last_hit: float = 0.0
@export var regen_delay: float = 5.0
@export var base_regen_rate: float = 2.0

func take_damage(amount: float):
	current_health -= amount
	time_since_last_hit = 0.0 
	
	# We DELETED the 'if current_health <= 0' check from here! 
	# The Brain just does the math and shuts up.

func die():
	# The Anti-Cheese Penalty! 
	current_health = 50.0 
	time_since_last_hit = 0.0
	print("Brain died. Health reset to 50.")

# We create a custom function here instead of _process
func process_regen(delta: float):
	if current_health < max_health and current_health > 0:
		time_since_last_hit += delta
		
		if time_since_last_hit >= regen_delay:
			var time_healing = time_since_last_hit - regen_delay
			var current_rate = base_regen_rate * pow(1.5, time_healing)
			
			current_health += current_rate * delta
			
			if current_health >= max_health:
				current_health = max_health
				time_since_last_hit = 0.0 # <--- FIX 1: Reset when full!
				print("Fully healed! Timer reset.")
var copper = 0
var current_tool = "Hand"
var tool_tier = 0 # 0 = Hand, 1 = Pickaxe, 2 = Laser, etc.
# Defaults to the crash site when you first start the game!
var target_spawn = "CrashSite"
# Keeps track of everything the player destroys
var destroyed_objects = []
