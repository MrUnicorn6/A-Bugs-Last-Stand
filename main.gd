extends Node

@onready var user_interface = preload("res://ui/ui.tscn").instantiate()
@onready var map = preload("res://gameplay/levels/map1/map1.tscn")
@onready var camera = preload("res://main/camera_scene.tscn")
var current_map
#static var packedBasicTowers:Dictionary
#static var packedSpecialTowers:Dictionary
static var packed_enemies:Dictionary
const Loader = preload("res://gameplay/gameplay_objects_loader.gd")

# Called when the node enters the scene tree for the first time.s
func _ready() -> void:
	#primary initiation stuff
	
	var all_towers_dict = Loader.towers_config
	print("MAPS SHOULD BE HANDELED BY A LEVEL LOADER(WIP)")
	var current_map = map.instantiate()
	current_map.set_enemies(Loader.enemies_config)
	current_map.set_goal()
	current_map.do_round()
	add_child(current_map)
	add_child(camera.instantiate())
	
	user_interface.start(current_map)
	add_child(user_interface)
	
	#these should be in UI
	user_interface.add_shop_item(all_towers_dict["ants"]["ant_tower"])
	#user_interface.add_shop_item(all_towers_dict["beetles"]["beetle"])
		
