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


func changeToUpgradeScreen(tower,upgrades):
	$ShopPanel.hide()
	var upgradePanel = $'UpgradePanel'
	
	upgradePanel.get_node("DisplaySprite").texture = tower.get_node('Sprite').texture
	upgradePanel.get_node("Label").text = tower.displayName
	
	if tower.upgradeCount == 0 && upgrades[0]!=null:
		var tempItem = BaseUpgradeItem.instantiate()
		tempItem.get_node("Sprite").texture = upgrades[0]["sprite"]
		tempItem.get_node("DescLabel").text = upgrades[0]["desc"]
		tempItem.get_node("CostLabel").text = str(upgrades[0]["cost"])
		tempItem.upgrade = tower.upgrades[0]
		tempItem.tower = tower
		$"UpgradePanel/UpgradeOptionsContainer".add_child(tempItem)
	if tower.upgradeCount == 1 && upgrades[1]!=null:
		var tempItem = BaseUpgradeItem.instantiate()
		tempItem.get_node("Sprite").texture = upgrades[1]["sprite"]
		tempItem.get_node("DescLabel").text = upgrades[1]["desc"]
		tempItem.get_node("CostLabel").text = str(upgrades[1]["cost"])
		tempItem.upgrade = tower.upgrades[1]
		tempItem.tower = tower
		$"UpgradePanel/UpgradeOptionsContainer".add_child(tempItem)
	upgradePanel.show()


func _on_button_pressed() -> void:
	$'UpgradePanel'.hide()
	#unsure if this works, regarless test upgrades screen after hitting back
	#and see if the correct upgrades appear
	for i in $'UpgradePanel/UpgradeOptionsContainer'.get_children():

		$'UpgradePanel'.remove_child(i)
	$'ShopPanel'.show()
	pass # Replace with function body.
