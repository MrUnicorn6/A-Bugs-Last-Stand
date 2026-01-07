extends Panel


@onready var tower = preload("res://Towers/red_tower.tscn")
var currentTile







func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_mask==1:
		print("pressed")
		var tempTower = tower.instantiate()
		add_child(tempTower)
		tempTower.global_position = event.global_position
		#disables turret while dragging
		tempTower.process_mode = Node.PROCESS_MODE_DISABLED

	elif event is InputEventMouseMotion and event.button_mask==1:
		get_child(1).global_position = event.global_position
	elif event is InputEventMouseButton and event.button_mask==0:
		if !event.pressed:
			print("released")
			#moving insance of tower to towers root and enabling the tower
			get_child(1).process_mode = Node.PROCESS_MODE_ALWAYS
			var targetDir = get_node("/root/Main/Towers")
			get_child(1).reparent(targetDir)
