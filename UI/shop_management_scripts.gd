extends Node

@onready var BaseShopItem = preload("res://UI/Shop Panel/BaseShopButton.tscn")
@onready var UI = load("res://UI/UI.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#put all future shop towers here, they will automatically be made into buttons
	addShopItem("res://SourceTowers/RedTower/Red_Tower.tscn",1000)
	addShopItem("res://SourceTowers/BoomTower/Boom_Tower.tscn",2000)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func addShopItem(TempTowerPath,cost):
	#takes in a absolute res:// path to a tower, and a cost 
	#and creates a shop item with it
	
	#instancing the tower so that we can get its texture and name
	var TowerTarget = load(TempTowerPath).instantiate()
	
	#actual button creation stuff
	var newButton = BaseShopItem.instantiate()
	
	#handing the path of each buttons respective towers to the buttons so they can
	#create their towers when needed.
	newButton.IntendedTowerPath = TempTowerPath
	newButton.get_node("Sprite").texture = load(TowerTarget.get_node("RedTowerSprite").texture.resource_path)
	newButton.get_node("NameLabel").text = TowerTarget.get_name()
	newButton.get_node("CostLabel").text = str(cost)
	$"../UIPanel/ShopOptionsContainer".add_child(newButton)
	
	
	TowerTarget.queue_free()
	


	
	
	
