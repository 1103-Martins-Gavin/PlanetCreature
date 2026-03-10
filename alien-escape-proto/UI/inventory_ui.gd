extends CanvasLayer

# Grab the container where the rows will go
@onready var loot_list = $Panel/ScrollContainer/LootList 
# Load our perfect row template
var item_row_scene = preload("res://UI/item_row.tscn")

func _ready():
	hide() 

func _process(_delta):
	if Input.is_action_just_pressed("toggle_inventory"):
		# If we are about to open the menu, refresh the list first!
		if not visible:
			update_loot_list()
			
		visible = !visible 
		get_tree().paused = visible 

func update_loot_list():
	for child in loot_list.get_children():
		child.queue_free()
		
	for item in Inventory.materials:
		var amount = Inventory.materials[item]
		
		if amount > 0:
			var new_row = item_row_scene.instantiate()
			loot_list.add_child(new_row)
			
			var display_name = item.capitalize()
			
			new_row.get_node("ItemName").text = display_name
			new_row.get_node("ItemQuantity").text = "x" + str(amount)
			
			# THE NEW LOGIC: Ask the visual memory bank for the picture!
			if Inventory.item_icons.has(item):
				new_row.get_node("ItemIcon").texture = Inventory.item_icons[item]
