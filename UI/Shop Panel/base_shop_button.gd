extends Panel

var IntendedTowerPath = ''





func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_mask==1:
		#print("pressed, tower path is",IntendedTowerPath)
		
		var tempTower = load(IntendedTowerPath).instantiate()
		var PlayerMoney = $"../../../HealthAndMoney".Money
		#print("tower cost is ",tempTower.shopCost,", money is ",PlayerMoney)
		if(int(tempTower.shopCost)<=int(PlayerMoney)):
			$"../../../HealthAndMoney".changeMoney(tempTower.shopCost)
			$TempTowerHolder.add_child(tempTower)
			tempTower.global_position = event.global_position
			#disables turret while dragging
			tempTower.process_mode = Node.PROCESS_MODE_DISABLED
		else:
			print("YOU CANNOT AFFORD THIS SHIT")
			

	elif event is InputEventMouseMotion and event.button_mask==1:
		if($TempTowerHolder.get_child_count()>0 ):
			$TempTowerHolder.get_child(0).global_position = event.global_position
	elif event is InputEventMouseButton and event.button_mask==0:
		if($TempTowerHolder.get_child_count()>0):
			if !event.pressed:
				#moving insance of tower to towers root and enabling the tower
				$TempTowerHolder.get_child(0).process_mode = Node.PROCESS_MODE_ALWAYS
				var targetDir = get_node("/root/Main/Towers")
				$TempTowerHolder.get_child(0).reparent(targetDir)
		
		
