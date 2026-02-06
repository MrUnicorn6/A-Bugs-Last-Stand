extends Node

@onready var UI = preload("res://UI/ui.tscn")
@onready var map = preload("res://Maps/Map1/Map1.tscn")
var currentMap
static var packedBasicTowers:Dictionary
static var packedSpecialTowers:Dictionary
static var packedEnemies:Dictionary
var GameplayObjectLoader = load("res://Gameplay/GameplayObjectsLoader.gd")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#primary initiation stuff
	
	packedBasicTowers = GameplayObjectLoader.getPackedBasicTowers()
	packedSpecialTowers = GameplayObjectLoader.getPackedSpecialTowers()
	packedEnemies = GameplayObjectLoader.getPackedEnemies()
	
	currentMap = map.instantiate()
	currentMap.getSpawnScriptNode().setEnemies(packedEnemies)
	currentMap.getSpawnScriptNode().setGoal()
	currentMap.getSpawnScriptNode().doRound()
	add_child(currentMap)
	
	
	
	
	UI = UI.instantiate()
	UI.mapObject = currentMap
	add_child(UI)

	for i in packedBasicTowers.keys():
		UI.addShopItem(packedBasicTowers[i])
		

static func getPackedSpecialTower(findName)->PackedScene:
	print("THIS METHOD SHOULD NOT BE IN MAIN")
	for i in packedSpecialTowers.keys():
		if i == findName:
			return packedSpecialTowers[findName]
	print("SPECAIL TOWER ",findName," NOT FOUND")
	return null
