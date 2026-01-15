extends Node

const BaseShopItem = preload("res://UI/Shop Panel/BaseShopButton.tscn")
var mapObject #set by main.gd
# Called when the node enters the scene tree for the first time.




func addShopItem(Tower):
	var newButton = BaseShopItem.instantiate()
	newButton.map = mapObject
	newButton.setIntendedTower(Tower)
	newButton.get_node("Sprite").texture = Tower.get_node("Sprite").texture
	newButton.get_node("NameLabel").text = Tower.get_name()
	newButton.get_node("CostLabel").text = str(Tower.shopCost)
	$"ShopPanel/ShopOptionsContainer".add_child(newButton)


func changeToUpgradeScreen(tower):
	$ShopPanel.hide()
	if tower.upgradeCount == 0:
		pass
	$UpgradePanel.show()
	
	pass
	


	
	
	
