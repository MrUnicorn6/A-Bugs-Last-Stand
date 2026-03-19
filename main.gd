extends Node

@onready var user_interface = preload("res://UI/ui.tscn").instantiate()
#@onready var map = preload("res://Maps/Map1/Map1.tscn")
var current_map
#static var packedBasicTowers:Dictionary
#static var packedSpecialTowers:Dictionary
static var packed_enemies:Dictionary
const loader = preload("res://Gameplay/gameplay_objects_loader.gd")

# Called when the node enters the scene tree for the first time.s
func _ready() -> void:
	#primary initiation stuff
	
	#packedBasicTowers = GameplayObjectLoader.getPackedBasicTowers()
	#packedSpecialTowers = GameplayObjectLoader.getPackedSpecialTowers()
	#packed_enemies = loader.getPackedEnemies()
	#var specialTower = GameplayObjectLoader.SpecialTowers[1]
	#loader._static_init()
	var all_towers_dict = loader.towers_config
	print("MAPS SHOULD BE HANDELED BY A LEVEL LOADER(WIP)")
	#currentMap = map.instantiate()
	#currentMap.getSpawnScriptNode().setEnemies(loader.enemies_config)
	#currentMap.getSpawnScriptNode().setGoal()
	#currentMap.getSpawnScriptNode().doRound()
	#add_child(currentMap)
	
	
	user_interface.start()
	
	#user_interface.mapObject = currentMap
	add_child(user_interface)
	
	#these should be in UI
	user_interface.add_shop_item(all_towers_dict["ants"]["ant"])
	user_interface.add_shop_item(all_towers_dict["beetles"]["beetle"])
		
