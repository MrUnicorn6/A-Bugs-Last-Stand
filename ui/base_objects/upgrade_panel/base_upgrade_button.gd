
extends Panel

##THE key of the upgrade to be given to be in tower.set_config()
var upgrade_config = null#set by upgrade_panel
static var upgrade_panel = null#set by upgrade_panel

func _gui_input(event: InputEvent) -> void:
	# Checks if the left mouse button was clicked down inside the panel
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			assert(upgrade_panel!=null,"UPGRADE PANEL NOT SET FOR BUTTON")
			assert(upgrade_config!=null,"TRIED TO UPGRADE TO BUTTON, BUT UPGRADE CONFIG IS NULL")
			upgrade_panel._on_upgrade_button_pressed(upgrade_config)
			pass
