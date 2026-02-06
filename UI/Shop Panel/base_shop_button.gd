extends MarginContainer

var IntendedTower = 'BAD'
var map 



func setIntendedTower(setTower):
	IntendedTower = setTower


func _on_base_shop_button_gui_input(event: InputEvent) -> void:
	print("CLICKED")
	#CLICKING THIS BUTTONS NOT WORKING RN
	#on mousedown
	if event is InputEventMouseButton and event.button_mask==1:
		var tempTower = IntendedTower.instantiate()
		var PlayerMoney = $"../../../HealthAndMoney".Money
		if(int(tempTower.shopCost)<=int(PlayerMoney)):
			
			$"../../../HealthAndMoney".changeMoney(tempTower.shopCost)
			$BaseShopButton/TempTowerHolder.add_child(tempTower)
			tempTower.global_position = event.global_position
			#disables turret while dragging
			tempTower.rotation_degrees -= 90
			tempTower.process_mode = Node.PROCESS_MODE_DISABLED
			tempTower.displayRange = true
			#print("TEMPTOWERHOLDERLEN IS ",$'TempTowerHolder'.get_children().size() )
		else:
			print("YOU CANNOT AFFORD THIS SHIT")
			
	#while holding it down
	elif event is InputEventMouseMotion and event.button_mask==1:
		if($BaseShopButton/TempTowerHolder.get_child_count()>0 ):
			$BaseShopButton/TempTowerHolder.get_child(0).global_position = event.global_position
			#var tiledata = map.get_cell_tile_data(map.local_to_map(map.to_local(event.global_position)))
			#print("CAN PUT HERE ",!tiledata.get_custom_data("NoPlaceArea"))
	#on mouseup
	elif event is InputEventMouseButton and event.button_mask==0:
		if($BaseShopButton/TempTowerHolder.get_child_count()>0):
			if !event.pressed:
				#moving insance of tower to towers root and enabling the tower if in a valid place area
				var tiledata = map.get_cell_tile_data(map.local_to_map(map.to_local(event.global_position)))
				if !tiledata.get_custom_data("NoPlaceArea"):
					$BaseShopButton/TempTowerHolder.get_child(0).process_mode = Node.PROCESS_MODE_ALWAYS
					$BaseShopButton/TempTowerHolder.get_child(0).displayRange = false
					var targetDir = get_node("/root/Main/Towers")
					$BaseShopButton/TempTowerHolder.get_child(0).reparent(targetDir)
					
				else:
					#print("CANNOT PLACE HERE")
					$BaseShopButton/TempTowerHolder.get_child(0).queue_free()
					$"../../../HealthAndMoney".changeMoney(-$TempTowerHolder.get_child(0).shopCost)
