extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
var can_move = false

# --- PLAYER STATS ---
var max_health: int = 5
var current_health: int = 5

# --- 1. NEW EQUIP SLOT ---
@export var equipped_tool: ToolData 

func _ready():
	$HUD/HealthLabel.text = "HP: " + str(current_health) + " / " + str(max_health)
	
	if equipped_tool != null:
		$Pivot.visible = true
		Inventory.current_tool = equipped_tool.tool_name
	else:
		$Pivot.visible = false
		Inventory.current_tool = "Hand"
		
	# We leave this here just as a backup safety net!
	if TransitionScreen.get_node("AnimationPlayer").is_playing():
		await TransitionScreen.get_node("AnimationPlayer").animation_finished
		
	can_move = true
	
func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	# --- THE BULLETPROOF LOCK ---
	# Is the screen currently fading?
	var is_fading = TransitionScreen.get_node("AnimationPlayer").is_playing()
	# Only allow input if the player is allowed to move AND the screen is perfectly clear!
	var player_has_control = can_move and not is_fading

	var direction = 0
	
	# 1. Read Inputs (Using our new lock!)
	if player_has_control:
		direction = Input.get_axis("ui_left", "ui_right")
		if Input.is_action_just_pressed("ui_accept") and is_on_floor():
			velocity.y = JUMP_VELOCITY

	# 2. Camera Look-Ahead Logic
	if direction > 0:
		$Camera2D.position.x = 100 
	elif direction < 0:
		$Camera2D.position.x = -100 
	else:
		$Camera2D.position.x = 0 
		
	# 3. Player Movement Logic
	if direction:
		velocity.x = direction * SPEED
		if direction > 0:
			$Pivot.position.x = 16
			$Pivot.scale.x = 1
		elif direction < 0:
			$Pivot.position.x = -16
			$Pivot.scale.x = -1
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	# 4. Swap Tools Logic (Using our new lock!)
	if player_has_control and Input.is_action_just_pressed("swap") and equipped_tool != null:
		$Pivot.visible = not $Pivot.visible 
		if $Pivot.visible:
			Inventory.current_tool = equipped_tool.tool_name
		else:
			Inventory.current_tool = "Hand"
			
	# 5. Swing Animation Logic (Using our new lock!)
	if player_has_control and Input.is_action_just_pressed("mine") and equipped_tool != null and $Pivot.visible:
		var tween = create_tween()
		tween.tween_property($Pivot, "rotation_degrees", 90.0, 0.1)
		tween.tween_property($Pivot, "rotation_degrees", 0.0, 0.1)
		
	move_and_slide()

func take_damage(amount: int):
	current_health -= amount
	$HUD/HealthLabel.text = "HP: " + str(current_health) + " / " + str(max_health)
	
	$ColorRect.modulate = Color.RED 
	await get_tree().create_timer(0.2).timeout
	$ColorRect.modulate = Color.WHITE
	
	if current_health <= 0:
		print("GAME OVER! YOU DIED!")
