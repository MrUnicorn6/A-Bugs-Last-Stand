extends Panel
class_name UpgradePanel
const BASE_UPGRADE_ITEM = preload("res://ui/base_objects/upgrade_panel/base_upgrade_button.tscn")

'''
func add_upgrade_item(to_be_upgraded_to_config,current_tower_config,tower_object):
	var temp_button = BASE_UPGRADE_ITEM.instantiate()
	temp_button.get_node("Sprite").texture = to_be_upgraded_to_config["tower_texture"]
	temp_button.get_node("DescLabel").text = to_be_upgraded_to_config["desc"]
	temp_button.get_node("CostLabel").text = str(to_be_upgraded_to_config["shop_cost"])
	temp_button.to_upgrade_to_config = to_be_upgraded_to_config
	temp_button.tower_config = current_tower_config
	temp_button.tower_object = tower_object
	#print("ADDING BUTTONS DISABLED RN")
	$"SidePanel/UpgradePanel/UpgradeOptionsContainer".add_child(temp_button)
	return temp_button
func change_to_upgrade_screen(tower_config,tower_object):
	print("REFACTOR THIS SHIT changetoupgradescreen()")
	
	var upgrade_option_configs =[]
	if tower_config["upgrade_options_config_keys"]!=null:
		for i in tower_config["upgrade_options_config_keys"]:
			upgrade_option_configs.append(i)
	print("this towers options",upgrade_option_configs)

	
	#check for existing upgradepanel items so that when clicking another tower
	# so the upgrades dont stack together
	if upgrade_panel.is_visible_in_tree():
		_on_back_button_pressed()
	$SidePanel/ShopPanel.hide()
	upgrade_panel.get_node("DisplaySprite").texture = tower_config["tower_texture"]
	upgrade_panel.get_node("Label").text = tower_config["display_name"]
	if upgrade_option_configs.size()!=0&&upgrade_option_configs!=null:
		for i in upgrade_option_configs:
			var temp_upgr_config = Loader.towers_config[tower_config["class"]][i]
			add_upgrade_item(temp_upgr_config,tower_config,tower_object)
		
	upgrade_panel.show()
	
	
	
	
## OLD STUFF FROM THE BASE UPGRADE BUTTON SCRIPT: 
	
	
extends Panel

var tower_config
var tower_object
var to_upgrade_to_config

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_mask==1:
		pass
	elif event is InputEventMouseMotion and event.button_mask==1:
		pass
	elif event is InputEventMouseButton and event.button_mask==0:
		if !event.pressed:
			#print("UPGRADE BUTTON CLICKED FOR TOWER ",tower.display_name)
			if(int(to_upgrade_to_config["shop_cost"])<=int($"../../../HealthAndMoney".money)):
				$"../../../HealthAndMoney".change_money(to_upgrade_to_config["shop_cost"])
				tower_object.set_config(to_upgrade_to_config)
				$'../../../../'.change_to_upgrade_screen(tower_config,tower_object)
					#update the panel to relfect upgrade, given its not a 
					#tower replacement upgrade
				
				queue_free() #remove this from the panel
				
			else:
				print("HEY SHITASS YOU CANNOT AFFORD THIS")


		
		

'''
static var _container:Node = null
static var current_selected_tower = null

func _ready() -> void:
	_container = $"UpgradeOptionsContainer"
	
	assert(_container!=null,"ERROR UI UPGRADE PANEL CONTAINER NOT SET PROPERLY")


func _add_upgrade_button(input_config:Dictionary):
	print("button added for key ",input_config)
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
	print("clearing upgrade options container")
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
