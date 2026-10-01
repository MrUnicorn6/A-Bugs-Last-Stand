extends Node
class_name MainUI
const Loader = preload("res://gameplay/gameplay_objects_loader.gd")
const BASE_SHOP_ITEM = preload("res://ui/base_objects/shop_panel/base_shop_button.tscn")

const BASE_LEVEL_TILE = preload("res://ui/base_objects/levels/base_level_tile.tscn")
#const main_menu_scene = preload("res://ui/MainMenu.tscn")
var map_object #set by main.gd
# Called when the node enters the scene tree for the first time.
@onready var upgrade_panel = $"SidePanel/UpgradePanel"
func get_upgrade_panel() ->UpgradePanel:
	return upgrade_panel


func start(map) -> void:
	map_object=map
	pass
	
func add_shop_item(tower:Dictionary):
	var new_button = BASE_SHOP_ITEM.instantiate()
	
	#give the map to the button, so that it can be used to check if 
	#its a valid place to put a tower
	new_button.map = map_object
	new_button.set_intended_tower(tower)
	new_button.get_node("BaseShopButton/Sprite").texture = tower.get("icon_texture",tower.get("tower_texture"))
	new_button.get_node("BaseShopButton/NameLabel").text = tower["display_name"]
	new_button.get_node("BaseShopButton/CostLabel").text = str(tower["shop_cost"])
	#print("ADDING BUTTONS DISABLED RN")
	$"SidePanel/ShopPanel/ShopOptionsContainer".add_child(new_button)
	#tower.queue_free()
func add_level_item(map:Dictionary):
	var temp = BASE_LEVEL_TILE.instantiate()
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
