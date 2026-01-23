extends Node

const BaseShopItem = preload("res://UI/Shop Panel/BaseShopButton.tscn")
const BaseUpgradeItem = preload("res://UI/UpgradePanel/BaseUpgradeButton.tscn")
var mapObject #set by main.gd
# Called when the node enters the scene tree for the first time.




func addShopItem(packedTower):
	var newButton = BaseShopItem.instantiate()
	var tempTower = packedTower.instantiate()
	newButton.map = mapObject
	newButton.setIntendedTower(packedTower)
	newButton.get_node("Sprite").texture = tempTower.get_node("Sprite").texture
	#print("NAME OF TOWER BEING ADDED IS ",tempTower.displayName)
	newButton.get_node("NameLabel").text = tempTower.displayName
	newButton.get_node("CostLabel").text = str(tempTower.shopCost)
	$"ShopPanel/ShopOptionsContainer".add_child(newButton)
	tempTower.queue_free()

func addUpgradeItem(spriteTex,desc,cost):
	var tempButton = BaseUpgradeItem.instantiate()
	tempButton.get_node("Sprite").texture = spriteTex
	tempButton.get_node("DescLabel").text = desc
	tempButton.get_node("CostLabel").text = str(cost)
	$"UpgradePanel/UpgradeOptionsContainer".add_child(tempButton)
	return tempButton
func changeToUpgradeScreen(tower,upgrades):
	var upgradePanel = $'UpgradePanel'
	#check for existing upgradepanel items so that when clicking another tower
	# so the upgrades dont stack together
	if upgradePanel.is_visible_in_tree():
		_on_back_button_pressed()
	$ShopPanel.hide()
	upgradePanel.get_node("DisplaySprite").texture = tower.get_node('Sprite').texture
	upgradePanel.get_node("Label").text = tower.displayName
	if upgrades.size()!=0:
		if tower.upgradeCount == 0 && upgrades[0]!=null:
			var tempItem = addUpgradeItem(upgrades[0]['sprite'],upgrades[0]['desc'],upgrades[0]['cost'])
			tempItem.upgrade = upgrades[0]
			tempItem.tower = tower
		if tower.upgradeCount == 1 && upgrades[1]!=null:
			var tempItem = addUpgradeItem(upgrades[1]['sprite'],upgrades[1]['desc'],upgrades[1]['cost'])
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
				var tempItem = addUpgradeItem(specialTower.get_node("Sprite").texture,obj["PathOne"]['desc'],obj["PathOne"]['cost'])
				tempItem.upgrade = obj["PathOne"]
				tempItem.nameOfSpecialTower = obj["PathOne"]["Tower"]
				tempItem.tower = tower
			if obj.has("PathTwo"):
				#print("option ",obj["PathTwo"]["Tower"]," found")
				var specialTower = $'../'.getPackedSpecialTower(obj["PathTwo"]["Tower"])
				specialTower = specialTower.instantiate()
				var tempItem = addUpgradeItem(specialTower.get_node("Sprite").texture,obj["PathTwo"]['desc'],obj["PathTwo"]['cost'])
				tempItem.upgrade = obj["PathTwo"]
				tempItem.nameOfSpecialTower = obj["PathTwo"]["Tower"]
				tempItem.tower = tower
			if obj.has("PathThree"):
				#print("option ",obj["PathThree"]["Tower"]," found")
				var specialTower = $'../'.getPackedSpecialTower(obj["PathThree"]["Tower"])
				specialTower = specialTower.instantiate()
				var tempItem = addUpgradeItem(specialTower.get_node("Sprite").texture,obj["PathThree"]['desc'],obj["PathThree"]['cost'])
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
