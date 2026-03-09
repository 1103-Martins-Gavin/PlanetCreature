extends Node2D
class_name BaseWeapon

@export var damage: int = 1
var is_attacking: bool = false

func attack():
	if is_attacking: return
	is_attacking = true
	
	# 1. Turn the hitbox ON safely using set_deferred (Godot's best practice for physics)
	$Hitbox/CollisionShape2D.set_deferred("disabled", false)
	
	# 2. The Visual Swing
	var tween = create_tween()
	tween.tween_property(self, "rotation_degrees", 90.0, 0.1)
	tween.tween_property(self, "rotation_degrees", 0.0, 0.1)
	
	# 3. Wait 0.1 seconds so the pickaxe reaches the middle of its swing!
	await get_tree().create_timer(0.1).timeout
	
	# 4. NOW check what we hit
	var things_hit = $Hitbox.get_overlapping_bodies()
	for thing in things_hit:
		if thing.has_method("take_damage") and thing.name != "Player":
			thing.take_damage(damage)
			print("Weapon smacked ", thing.name, " for ", damage, " damage!")
			
	# Wait for the animation to completely finish
	await tween.finished
	
	# 5. Turn the hitbox back OFF
	$Hitbox/CollisionShape2D.set_deferred("disabled", true)
	is_attacking = false
