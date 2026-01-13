extends Node

const BaseShopItem = preload("res://UI/Shop Panel/BaseShopButton.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#put all future shop towers here, they will automatically be made into buttons
	#addShopItem(load("res://SourceTowers/RedTower/Red_Tower.tscn"))
	#addShopItem("res://SourceTowers/BoomTower/Boom_Tower.tscn",2000)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func addShopItem(Tower):
	#print(Tower.BulletObject.guidance)
	#instancing the tower so that we can get its texture and name
	print("TOWER BEING ADDED TO SHOP NAME IS ",Tower.get_name(),Tower.maxRange,Tower.BulletObject)
	
	#actual button creation stuff
	var newButton = BaseShopItem.instantiate()
	#handing the path of each buttons respective towers to the buttons so they can
	#create their towers when needed.
	newButton.setIntendedTower(Tower)
	newButton.get_node("Sprite").texture = Tower.get_node("Sprite").texture
	newButton.get_node("NameLabel").text = Tower.get_name()
	newButton.get_node("CostLabel").text = str(Tower.shopCost)
	$"../UIPanel/ShopOptionsContainer".add_child(newButton)
	
	
	#TowerTarget.queue_free()
	


	
	
	
