extends Node
const loader = preload("res://Gameplay/gameplay_objects_loader.gd")
const base_shop_item = preload("res://UI/BaseObjects/Shop Panel/BaseShopButton.tscn")
const base_upgrade_item = preload("res://UI/BaseObjects/UpgradePanel/BaseUpgradeButton.tscn")
const base_level_tile = preload("res://UI/BaseObjects/Levels/BaseLevelTile.tscn")
#const main_menu_scene = preload("res://UI/MainMenu.tscn")
var mapObject #set by main.gd
# Called when the node enters the scene tree for the first time.



func start() -> void:
	pass
	
func add_shop_item(tower:Dictionary):
	var newButton = base_shop_item.instantiate()
	
	#give the map to the button, so that it can be used to check if 
	#its a valid place to put a tower
	newButton.map = mapObject
	newButton.setIntendedTower(tower)
	newButton.get_node("BaseShopButton/Sprite").texture = tower["icon_texture"]
	newButton.get_node("BaseShopButton/NameLabel").text = tower["display_name"]
	newButton.get_node("BaseShopButton/CostLabel").text = str(tower["shop_cost"])
	#print("ADDING BUTTONS DISABLED RN")
	$"SidePanel/ShopPanel/ShopOptionsContainer".add_child(newButton)
	#tower.queue_free()
func add_level_item(map:Dictionary):
	var temp = base_level_tile.instantiate()
	temp.get_node("TextureRect").texture =map["preview"]
	temp.get_node("Desc").text = map["desc"]
	temp.get_node("LevelName").text = map["name"]
func add_upgrade_item(spriteTex,desc,cost):
	var tempButton = base_upgrade_item.instantiate()
	tempButton.get_node("Sprite").texture = spriteTex
	tempButton.get_node("DescLabel").text = desc
	tempButton.get_node("CostLabel").text = str(cost)
	#print("ADDING BUTTONS DISABLED RN")
	$"UpgradePanel/UpgradeOptionsContainer".add_child(tempButton)
	return tempButton
func change_to_upgrade_screen(tower,upgrades):
	print("REFACTOR THIS SHIT changetoupgradescreen()")
	var upgradePanel = $'SidePanel/UpgradePanel'
	#check for existing upgradepanel items so that when clicking another tower
	# so the upgrades dont stack together
	if upgradePanel.is_visible_in_tree():
		_on_back_button_pressed()
	$SidePanel/ShopPanel.hide()
	upgradePanel.get_node("DisplaySprite").texture = tower.get_node('Sprite').texture
	upgradePanel.get_node("Label").text = tower.displayName
	if upgrades.size()!=0:
		if tower.upgradeCount == 0 && upgrades[0]!=null:
			var tempItem = add_upgrade_item(upgrades[0]['sprite'],upgrades[0]['desc'],upgrades[0]['cost'])
			tempItem.upgrade = upgrades[0]
			tempItem.tower = tower
		if tower.upgradeCount == 1 && upgrades[1]!=null:
			var tempItem = add_upgrade_item(upgrades[1]['sprite'],upgrades[1]['desc'],upgrades[1]['cost'])
			tempItem.upgrade = upgrades[1]
			tempItem.tower = tower
		if tower.upgradeCount == 2 && upgrades[2] !=null:
			#print("SHOWING PATH OPTIONS")
			var obj = upgrades[2]
			if obj.has("PathOne"):
				#print("option ",obj["PathOne"]["Tower"]," found")
				var specialTower = $'../'.getPackedSpecialTower(obj["PathOne"]["Tower"])
				specialTower = specialTower.instantiate()
				#get the packed tower for the respective Tower, to grab its sprite as well
				var tempItem = add_upgrade_item(specialTower.get_node("Sprite").texture,obj["PathOne"]['desc'],obj["PathOne"]['cost'])
				tempItem.upgrade = obj["PathOne"]
				tempItem.nameOfSpecialTower = obj["PathOne"]["Tower"]
				tempItem.tower = tower
			if obj.has("PathTwo"):
				#print("option ",obj["PathTwo"]["Tower"]," found")
				var specialTower = $'../'.getPackedSpecialTower(obj["PathTwo"]["Tower"])
				specialTower = specialTower.instantiate()
				var tempItem = add_upgrade_item(specialTower.get_node("Sprite").texture,obj["PathTwo"]['desc'],obj["PathTwo"]['cost'])
				tempItem.upgrade = obj["PathTwo"]
				tempItem.nameOfSpecialTower = obj["PathTwo"]["Tower"]
				tempItem.tower = tower
			if obj.has("PathThree"):
				#print("option ",obj["PathThree"]["Tower"]," found")
				var specialTower = $'../'.getPackedSpecialTower(obj["PathThree"]["Tower"])
				specialTower = specialTower.instantiate()
				var tempItem = add_upgrade_item(specialTower.get_node("Sprite").texture,obj["PathThree"]['desc'],obj["PathThree"]['cost'])
				tempItem.upgrade = obj["PathThree"]
				tempItem.nameOfSpecialTower = obj["PathThree"]["Tower"]
				tempItem.tower = tower
			
		
	upgradePanel.show()




func _on_back_button_pressed() -> void:
	#this is the back button from the upgrade panel of a tower to the towers panel
	$'UpgradePanel'.hide()
	for i in $'UpgradePanel/UpgradeOptionsContainer'.get_children():
		i.queue_free()
	$'ShopPanel'.show()

##when the main menus play button is clicked
func _on_play_button_pressed() -> void:
	$'MainMenu'.hide()
	
	$'LevelSelect'.show()
	
	
	pass # Replace with function body.
