
extends Panel

# This allows other scripts to read or change panel.pressed
var pressed: bool = false 

func _gui_input(event: InputEvent) -> void:
	# Checks if the left mouse button was clicked down inside the panel
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			print("UPGRADE BUTTON PRESSED, NOT FUNCTIONAL, OR BOUND PROPERLY")
			pass
