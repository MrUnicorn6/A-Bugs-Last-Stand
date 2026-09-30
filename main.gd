extends Node

@onready var user_interface = preload("res://UI/ui.tscn").instantiate()
@onready var map = preload("res://Gameplay/Levels/Map1/Map1.tscn")
@onready var camera = preload("res://Main/CameraScene.tscn")
var current_map
#static var packedBasicTowers:Dictionary
#static var packedSpecialTowers:Dictionary
static var packed_enemies:Dictionary
const loader = preload("res://Gameplay/gameplay_objects_loader.gd")

# Called when the node enters the scene tree for the first time.s
func _ready() -> void:
	#primary initiation stuff
	
	var all_towers_dict = loader.towers_config
	print("MAPS SHOULD BE HANDELED BY A LEVEL LOADER(WIP)")
	var currentMap = map.instantiate()
	currentMap.setEnemies(loader.enemies_config)
	currentMap.setGoal()
	currentMap.doRound()
	add_child(currentMap)
	add_child(camera.instantiate())
	
	user_interface.start(currentMap)
	add_child(user_interface)
	
	#these should be in UI
	user_interface.add_shop_item(all_towers_dict["ants"]["ant"])
	user_interface.add_shop_item(all_towers_dict["beetles"]["beetle"])
		
