extends Panel
class_name UpgradePanel
const Enums = preload("res://main/enums.gd")
const BASE_UPGRADE_ITEM = preload("res://ui/base_objects/upgrade_panel/base_upgrade_button.tscn")
static var _container:Node = null
static var current_selected_tower = null
static var _move_target_pending: bool = false
@onready var targeting_button: Button = $TargetingButton
@onready var movement_button: Button = $MovementButton

func _ready() -> void:
	_container = $"UpgradeOptionsContainer"
	assert(_container!=null,"ERROR UI UPGRADE PANEL CONTAINER NOT SET PROPERLY")
	if targeting_button != null:
		targeting_button.pressed.connect(_on_targeting_cycle_pressed)
	if movement_button != null:
		movement_button.pressed.connect(_on_set_move_target_pressed)

func _input(event: InputEvent) -> void:
	if !_move_target_pending or current_selected_tower == null:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var viewport := get_viewport()
		var camera: Camera2D = viewport.get_camera_2d()
		var mouse_position: Vector2 = viewport.get_mouse_position()
		var world_position: Vector2 = mouse_position
		if camera != null:
			var viewport_size: Vector2 = viewport.get_visible_rect().size
			world_position = camera.global_position + (mouse_position - viewport_size * 0.5)
		current_selected_tower.set_move_target_position(world_position)
		_move_target_pending = false
		_update_action_buttons()


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
	_update_action_buttons()
	
	
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

func _update_action_buttons() -> void:
	if current_selected_tower == null:
		return
	if movement_button != null:
		movement_button.text = "Move" if !_move_target_pending else "Click to place"
	if targeting_button != null:
		var curr: int = int(current_selected_tower.get_config().get("targeting", Enums.TargetingType.FIRST))
		targeting_button.text = "Targeting: " + _targeting_name(curr)
		targeting_button.disabled = current_selected_tower.get_targeting_options().size() <= 1

func _targeting_name(targeting_type: int) -> String:
	if targeting_type == Enums.TargetingType.CLOSEST:
		return "Closest"
	if targeting_type == Enums.TargetingType.STRONGEST:
		return "Strongest"
	if targeting_type == Enums.TargetingType.LAST:
		return "Last"
	return "First"

func _on_set_move_target_pressed() -> void:
	if current_selected_tower == null:
		return
	_move_target_pending = !_move_target_pending
	_update_action_buttons()
	if !_move_target_pending:
		current_selected_tower.clear_move_target_position()

func _on_targeting_cycle_pressed() -> void:
	if current_selected_tower == null:
		return
	var new_type: int = current_selected_tower.cycle_targeting_type()
	if targeting_button != null:
		targeting_button.text = "Targeting: " + _targeting_name(new_type)
		
func _on_upgrade_button_pressed(to_upgrade_config:Dictionary):
	#pay for it and stuff
	print("PAYING FOR UPGRADES NIY")
	current_selected_tower.set_config(to_upgrade_config)
	#clear and update panel for newly applied upgrade
	set_to_upgrades_for_tower(current_selected_tower)
