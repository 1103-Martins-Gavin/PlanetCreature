extends CanvasLayer

@warning_ignore("unused_parameter")
func _process(delta):
	$Label.text = "Copper: " + str(Inventory.copper) + " | Tool: " + Inventory.current_tool
