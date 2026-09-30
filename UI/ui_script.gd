extends Node
class_name MainUI
const loader = preload("res://Gameplay/gameplay_objects_loader.gd")
const base_shop_item = preload("res://UI/BaseObjects/Shop Panel/BaseShopButton.tscn")

const base_level_tile = preload("res://UI/BaseObjects/Levels/BaseLevelTile.tscn")
#const main_menu_scene = preload("res://UI/MainMenu.tscn")
var mapObject #set by main.gd
# Called when the node enters the scene tree for the first time.
@onready var upgrade_panel = $"SidePanel/UpgradePanel"
func get_upgrade_panel() ->UpgradePanel:
	return upgrade_panel


func start(map) -> void:
	mapObject=map
	pass
	
func add_shop_item(tower:Dictionary):
	var newButton = base_shop_item.instantiate()
	
	#give the map to the button, so that it can be used to check if 
	#its a valid place to put a tower
	newButton.map = mapObject
	newButton.setIntendedTower(tower)
	newButton.get_node("BaseShopButton/Sprite").texture = tower.get("icon_texture",tower.get("tower_texture"))
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




func _on_back_button_pressed() -> void:
	#this is the back button from the upgrade panel of a tower to the towers panel
	$'SidePanel/UpgradePanel'.hide()
	for i in $'SidePanel/UpgradePanel/UpgradeOptionsContainer'.get_children():
		i.queue_free()
	$'SidePanel/ShopPanel'.show()

##when the main menus play button is clicked
func _on_play_button_pressed() -> void:
	#print("SWAWS")
	$'MainMenu'.hide()
	$'SidePanel'.show()
	
	
	
	
	pass # Replace with function body.
