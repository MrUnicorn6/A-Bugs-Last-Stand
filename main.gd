extends Node

@onready var UI = preload("res://UI/ui.tscn")
@onready var map = preload("res://Maps/Map1/Map1.tscn")
var currentMap
#static var packedBasicTowers:Dictionary
#static var packedSpecialTowers:Dictionary
static var packed_enemies:Dictionary
var loader = load("res://Gameplay/GameplayObjectsLoader.gd")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#primary initiation stuff
	
	#packedBasicTowers = GameplayObjectLoader.getPackedBasicTowers()
	#packedSpecialTowers = GameplayObjectLoader.getPackedSpecialTowers()
	packed_enemies = loader.getPackedEnemies()
	#var specialTower = GameplayObjectLoader.SpecialTowers[1]
	var all_towers_dict = loader.towers_config
	
	currentMap = map.instantiate()
	currentMap.getSpawnScriptNode().setEnemies(packed_enemies)
	currentMap.getSpawnScriptNode().setGoal()
	currentMap.getSpawnScriptNode().doRound()
	add_child(currentMap)
	
	
	
	
	var currentUI = UI.instantiate()
	currentUI.mapObject = currentMap
	add_child(currentUI)

	
	currentUI.addShopItem(all_towers_dict["ants"]["ant"])
		
"""
static func getPackedSpecialTower(findName)->PackedScene:
	print("THIS METHOD SHOULD NOT BE IN MAIN")
	for i in packedSpecialTowers.keys():
		if i == findName:
			return packedSpecialTowers[findName]
	print("SPECAIL TOWER ",findName," NOT FOUND")
	return null
"""
