extends Panel

var IntendedTowerPath = ''
# Called when the node enters the scene tree for the first time.



func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_mask==1:
		print("pressed, tower path is",IntendedTowerPath)
		
		var tempTower = load(IntendedTowerPath).instantiate()
		#print(tempTower.get_children())
		$TempTowerHolder.add_child(tempTower)
		#print("All Children Are: ",get_children())
		tempTower.global_position = event.global_position

		print(tempTower.global_position)
		#disables turret while dragging
		tempTower.process_mode = Node.PROCESS_MODE_DISABLED

	elif event is InputEventMouseMotion and event.button_mask==1:
		$TempTowerHolder.get_child(0).global_position = event.global_position
	elif event is InputEventMouseButton and event.button_mask==0:
		if !event.pressed:
			#moving insance of tower to towers root and enabling the tower
			$TempTowerHolder.get_child(0).process_mode = Node.PROCESS_MODE_ALWAYS
			var targetDir = get_node("/root/Main/Towers")
			$TempTowerHolder.get_child(0).reparent(targetDir)
