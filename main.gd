extends Node2D
@onready var Path = preload("res://Maps/BaseMapPath.tscn")
@onready var BaseEnemy = preload("res://Enemies/EnemyBase.tscn")
@onready var BlankTower = preload("res://Towers/BaseTower/Base_Tower.tscn")
@onready var BlankBullet = preload("res://Towers/BaseTower/Base_Bullet.tscn")
#@onready var shopUI = preload("res://UI/shop_management_scripts.gd")
@onready var UI = preload("res://UI/ui.tscn")
@onready var testingAtlas = preload("res://Assets/towerDefense_tilesheet.png")
const Enums = preload("res://Main/ENUMS.gd")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#primary initiation stuff
	UI = UI.instantiate()
	add_child(UI)

	BlankTower = BlankTower.instantiate()
	BlankBullet = BlankBullet.instantiate()
	#creation of all towers
	var redTower = BlankTower.duplicate()
	var redBullet = BlankBullet.duplicate()
	#greenTowerData = TowerMetaData.new()
	var boomTower = BlankTower.duplicate()
	var boomBullet = BlankBullet.duplicate()
	boomBullet.setBulletValues(
				200,
				Enums.GuidanceTypes.DUMB,
				10,
				10,
				getAtlasAreaGrid(testingAtlas,22,10,64))
	
	redBullet.setBulletValues(
				300,
				Enums.GuidanceTypes.SMART,
				5,
				0,
				getAtlasAreaGrid(testingAtlas,21,10,64))
	
	redTower.setThisTowersValues(
			'BlueTower', Enums.TargetingTypes.CLOSEST,
			0,20,1,5,# setMinRange,setMaxRange,setFireRate,setShopCost
			redBullet,
			getAtlasAreaGrid(testingAtlas,20,10,64))

	boomTower.setThisTowersValues(
			'BoomTower', Enums.TargetingTypes.CLOSEST,
			10,30,0.5,10,# setMinRange,setMaxRange,setFireRate,setShopCost
			boomBullet,
			getAtlasAreaGrid(testingAtlas,20,8,64))
	UI.get_node("ShopManagementScripts").addShopItem(boomTower)

	UI.get_node("ShopManagementScripts").addShopItem(redTower)
	





func _on_spawn_timer_timeout() -> void:
	var Enemy1 = Path.instantiate()
	
	
	
#for loading sections of a atlas texture:
static func getAtlasAreaGrid(atlas: Texture2D,col: int,row: int,cell_size) -> AtlasTexture:  
	var tex := AtlasTexture.new()
	tex.atlas = atlas
	var rownumb = row*cell_size
	var colnumb = col*cell_size
	tex.region = Rect2(
		colnumb,
		rownumb,
		cell_size,
		cell_size)
	return tex
