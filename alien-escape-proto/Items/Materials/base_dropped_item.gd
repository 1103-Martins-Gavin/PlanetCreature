extends RigidBody2D
class_name BaseDroppedItem

@export var item_data: ItemData 

var target_player: Node2D = null
var magnet_speed: float = 300.0
var can_magnetize: bool = false # <--- THE NEW SAFETY LOCK!

func _ready():
	if item_data != null and item_data.item_icon != null:
		$Sprite2D.texture = item_data.item_icon
		
	# THE DELAY: Wait 0.6 seconds before unlocking the magnet!
	# (You can tweak this number to make the delay longer or shorter)
	await get_tree().create_timer(0.6).timeout
	can_magnetize = true

func _physics_process(_delta):
	# Only fly at the player if the delay timer has actually finished!
	if target_player != null and can_magnetize:
		gravity_scale = 0.0
		var direction = global_position.direction_to(target_player.global_position)
		linear_velocity = direction * magnet_speed
		
		if global_position.distance_to(target_player.global_position) < 20.0:
			collect_item()
	else:
		gravity_scale = 1.0

func collect_item():
	if item_data != null:
		print("Sucked up: ", item_data.item_name)
		
		var material_id = item_data.item_name.to_lower().replace(" ", "_")
		
		# THE FIX: We are now passing the icon along with the ID and the amount!
		Inventory.add_material(material_id, 1, item_data.item_icon) 
		
	else:
		print("Sucked up an item with no data!")
		
	queue_free()
	
# --- SIGNALS ---
func _on_magnet_zone_body_entered(body):
	if body.name == "Player":
		target_player = body

func _on_magnet_zone_body_exited(body):
	if body.name == "Player":
		target_player = null
