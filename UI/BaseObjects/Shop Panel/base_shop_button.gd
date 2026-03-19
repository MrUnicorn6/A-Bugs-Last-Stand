extends MarginContainer

var intended_tower_config:Dictionary = {}
var map 
const loader = preload("res://Gameplay/gameplay_objects_loader.gd")



func setIntendedTower(set_tower:Dictionary):
	#print("setting node of shop button to ",set_tower)
	intended_tower_config = set_tower


func _on_base_shop_button_gui_input(event: InputEvent) -> void:
	#on mousedown
	#var actual_event_position = event.global_position + get_node("/root/Main/Camera2D").global_position
	if event is InputEventMouseButton and event.button_mask==1:
		assert(intended_tower_config!={},"Shop Button clicked, but no intended tower was set")
		var temp_tower = loader.instance_tower(intended_tower_config)
		var PlayerMoney = $"../../../HealthAndMoney".Money
		
		if(int(intended_tower_config["shop_cost"])<=int(PlayerMoney)):
			#print("THIS IS ALL FUCKED HERE IN BASESHOPBUTTON")
			$"../../../HealthAndMoney".changeMoney(intended_tower_config["shop_cost"])
			$BaseShopButton/TempTowerHolder.add_child(temp_tower)
			temp_tower.global_position = event.global_position
			#disables turret while dragging
			temp_tower.rotation_degrees -= 90
			temp_tower.process_mode = Node.PROCESS_MODE_DISABLED
			temp_tower.draw_range = true
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
		if($BaseShopButton/TempTowerHolder.get_child_count()>0 && $BaseShopButton/TempTowerHolder.get_child(0)!=null):
			if !event.pressed:
				#moving insance of tower to towers root and enabling the tower if in a valid place area
				var tiledata = map.get_cell_tile_data(map.local_to_map(map.to_local(get_node("/root/Main/CoreGameNode/Towers").get_global_mouse_position())))
				if !tiledata.get_custom_data("NoPlaceArea"):
					$BaseShopButton/TempTowerHolder.get_child(0).global_position = get_node("/root/Main/CoreGameNode/Towers").get_global_mouse_position()
					$BaseShopButton/TempTowerHolder.get_child(0).process_mode = Node.PROCESS_MODE_ALWAYS
					$BaseShopButton/TempTowerHolder.get_child(0).draw_range = false
					#print("TOWER PLACED AT ",$BaseShopButton/TempTowerHolder.get_child(0).global_position)
					#print("TOWER BULLET POINT IS ",$BaseShopButton/TempTowerHolder.get_child(0).get_node("BulletSpawnPoint").global_position)
					var targetDir = get_node("/root/Main/CoreGameNode/Towers")
					$BaseShopButton/TempTowerHolder.get_child(0).reparent(targetDir)
					
					
				else:
					print("CANNOT PLACE HERE")
					$"../../../HealthAndMoney".changeMoney(-$BaseShopButton/TempTowerHolder.get_child(0)._config["shop_cost"])
					$BaseShopButton/TempTowerHolder.get_child(0).queue_free()
					
