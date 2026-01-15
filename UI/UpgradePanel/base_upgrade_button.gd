extends Panel

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_mask==1:
		pass
	elif event is InputEventMouseMotion and event.button_mask==1:
		pass
	elif event is InputEventMouseButton and event.button_mask==0:
		pass #on click

		
		
