extends Panel
class_name UpgradePanel
const BASE_UPGRADE_ITEM = preload("res://ui/base_objects/upgrade_panel/base_upgrade_button.tscn")
static var _container:Node = null
static var current_selected_tower = null

func _ready() -> void:
	_container = $"UpgradeOptionsContainer"
	
	assert(_container!=null,"ERROR UI UPGRADE PANEL CONTAINER NOT SET PROPERLY")


func _add_upgrade_button(input_config:Dictionary):
	#print("button added for key ",input_config)
	var button = BASE_UPGRADE_ITEM.instantiate()
	button.get_node("Sprite").texture = input_config["tower_texture"]
	button.get_node("DescLabel").text = input_config["desc"]
	button.get_node("CostLabel").text = str(input_config["shop_cost"])
	button.upgrade_config = input_config
	button.upgrade_panel = self
	#button.pressed.connect(_on_upgrade_button_pressed.bind(input_config))
	_container.add_child(button)
	
func set_to_upgrades_for_tower(tower_to_set_to:BaseTower):
	current_selected_tower = tower_to_set_to
	var config = current_selected_tower.get_config()
	print("setting upgrade container to ",config["display_name"])
	_clear_container()
	$'DisplaySprite'.texture = config["tower_texture"]
	var labelin = $"Label"
	labelin.text = config["display_name"]
	
	$"../ShopPanel".hide()
	show()
	
	_create_button_array()
	
	
	#head things like the name of the tower that was clicked and stuff
	
	
static func _clear_container():
	#print("clearing upgrade options container")
	if _container==null:
		return
	for i in _container.get_children():
		i.queue_free()
	
func _create_button_array():
	var options = current_selected_tower.get_config()["upgrade_options_config_keys"]
	for i in options:
		var x = GameplayObjectsLoader.get_tower(i)
		_add_upgrade_button(x)
		
func _on_upgrade_button_pressed(to_upgrade_config:Dictionary):
	#pay for it and stuff
	print("PAYING FOR UPGRADES NIY")
	current_selected_tower.set_config(to_upgrade_config)
	#clear and update panel for newly applied upgrade
	set_to_upgrades_for_tower(current_selected_tower)
