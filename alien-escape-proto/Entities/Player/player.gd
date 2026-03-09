extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
var can_move = false

# This grabs your exact starting location the moment the game boots up!
var active_spawn_point: Vector2
# --- HOTBAR INVENTORY ---
@export var hotbar: Array[ToolData] = [null, null, null]
var current_slot: int = 0

func _ready():
	# 1. Equip the first slot right when we spawn!
	equip_slot(0) 
	
	# 2. Wait for the fade-in screen to finish before letting the player walk
	if TransitionScreen.get_node("AnimationPlayer").is_playing():
		await TransitionScreen.get_node("AnimationPlayer").animation_finished
	can_move = true
	
	
func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	var is_fading = TransitionScreen.get_node("AnimationPlayer").is_playing()
	var player_has_control = can_move and not is_fading

	var direction = 0
	
	if player_has_control:
		direction = Input.get_axis("ui_left", "ui_right")
		if Input.is_action_just_pressed("ui_accept") and is_on_floor():
			velocity.y = JUMP_VELOCITY

	if direction > 0:
		$Camera2D.position.x = 100 
	elif direction < 0:
		$Camera2D.position.x = -100 
	else:
		$Camera2D.position.x = 0 
		
	# 3. Player Movement Logic
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
			
	# --- 360 DEGREE AIMING ---
	if player_has_control:
		# The anchor instantly rotates to point exactly at your mouse cursor!
		$WeaponAnchor.look_at(get_global_mouse_position())
		
	# --- SWING LOGIC ---
	if player_has_control and Input.is_action_just_pressed("mine") and $WeaponAnchor.visible:
		if $WeaponAnchor.get_child_count() > 0:
			var current_weapon = $WeaponAnchor.get_child(0)
			if current_weapon.has_method("attack"):
				current_weapon.attack()
				
	move_and_slide()

func take_damage(amount: float):
	if Inventory != null and Inventory.has_method("take_damage"):
		Inventory.take_damage(amount)
		
		# NOW the Player actually catches the 0!
		if Inventory.current_health <= 0:
			die()

func die():
	Inventory.die() 
	
	# Print the coordinates BEFORE we move
	print("--- DEATH DEBUG ---")
	print("1. I died at coordinates: ", global_position)
	print("2. I am TRYING to teleport to: ", active_spawn_point)
	
	# Force the standard teleport
	global_position = active_spawn_point
	
	# Print the coordinates AFTER we move
	print("3. My new coordinates are now: ", global_position)
	print("-------------------")
	
# --- INVENTORY & HOTBAR LOGIC ---
func _unhandled_input(event):
	# Listen for the 1, 2, and 3 keys on the keyboard to swap slots
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_1:
			equip_slot(0)
		elif event.keycode == KEY_2:
			equip_slot(1)
		elif event.keycode == KEY_3:
			equip_slot(2)

func equip_slot(index: int):
	current_slot = index
	
	# 1. Delete whatever weapon is currently attached to the anchor
	for child in $WeaponAnchor.get_children():
		child.queue_free()
		
	var item = hotbar[current_slot]
	
	# 2. Check if the new slot actually has a tool in it
	if item != null and item.weapon_scene != null:
		# Build the weapon and snap it onto the anchor!
		var new_weapon = item.weapon_scene.instantiate()
		$WeaponAnchor.add_child(new_weapon)
		$WeaponAnchor.visible = true
		Inventory.current_tool = item.tool_name
		
		# Optional: Pass the damage stat from the Resource directly into the Weapon Scene!
		new_weapon.damage = item.damage 
	else:
		# Empty slot (Hands)
		$WeaponAnchor.visible = false
		Inventory.current_tool = "Hand"
		
func _process(delta):
	if Inventory != null:
		Inventory.process_regen(delta)
		
		# 1. Update the actual bar
		$CanvasLayer/ProgressBar.value = Inventory.current_health
		
		# 2. Chop off the decimals and update the text Label!
		# We use str() to turn the math numbers into readable text.
		var clean_health = int(Inventory.current_health)
		var clean_max = int(Inventory.max_health)
		
		$CanvasLayer/ProgressBar/Label.text = str(clean_health) + " / " + str(clean_max)
