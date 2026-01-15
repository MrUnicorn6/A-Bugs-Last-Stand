extends Node2D
@onready var Path = preload("res://Maps/BaseMapPath.tscn")
@onready var BaseEnemy = preload("res://Enemies/EnemyBase.tscn")
@onready var BlankTower = preload("res://Towers/BaseTower/Base_Tower.tscn")
@onready var BlankBullet = preload("res://Towers/BaseTower/Base_Bullet.tscn")
#@onready var shopUI = preload("res://UI/shop_management_scripts.gd")
@onready var UI = preload("res://UI/ui.tscn")
@onready var testingAtlas = preload("res://Assets/towerDefense_tilesheet.png")
@onready var BugAtlas = preload("res://Assets/BugAtlas.png")
@onready var map = preload("res://Maps/Map1/Map1.tscn")
const Enums = preload("res://Main/ENUMS.gd")
var currentMap

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#primary initiation stuff
	currentMap = map.instantiate()
	currentMap.z_index = -10
	add_child(currentMap)
	
	UI = UI.instantiate()
	UI.mapObject = currentMap
	add_child(UI)

	BlankTower = BlankTower.instantiate()
	BlankBullet = BlankBullet.instantiate()
	#creation of all towers
	var Towers = [
		BlankTower.duplicate().setThisTowersValues(
			'Ant', Enums.TargetingTypes.FIRST,
			Enums.CanSeeCamo.CANNOTSEECAMO,
			0,300,1,5,# setMinRange,setMaxRange,setFireRate,setShopCost
			BlankBullet.duplicate().setBulletValues(
				200,Enums.GuidanceTypes.SMART,#bulletspeed
				5,Enums.Fuses.IMPACT, #damage
				0, #fuse value, unused if not proxy(its radius, might never use it or penetrations) 
				null, #status object
				0,#AOE
				getAtlasAreaGrid(testingAtlas,22,10,64)
			),
			getAtlasAreaGrid(BugAtlas,2,2,32)
		),BlankTower.duplicate().setThisTowersValues(
			'Beetle', Enums.TargetingTypes.CLOSEST,
			Enums.CanSeeCamo.CANNOTSEECAMO,
			0,200,1,5,# setMinRange,setMaxRange,setFireRate,setShopCost
			BlankBullet.duplicate().setBulletValues(
				200,Enums.GuidanceTypes.SMART,#bulletspeed
				10,Enums.Fuses.IMPACT, #damage
				0, #fuse value, unused if not proxy(its radius, might never use it or penetrations) 
				null, #status object
				0,#AOE
				getAtlasAreaGrid(testingAtlas,22,10,64)
			),
			getAtlasAreaGrid(BugAtlas,2,1,32)
		),BlankTower.duplicate().setThisTowersValues(
			'BoomTower', Enums.TargetingTypes.CLOSEST,
			Enums.CanSeeCamo.CANNOTSEECAMO,
			10,600,0.25,10,# setMinRange,setMaxRange,setFireRate,setShopCost
			BlankBullet.duplicate().setBulletValues(
				300,Enums.GuidanceTypes.DUMB,
				0,Enums.Fuses.TIMER,0, #fuse value, unused if not proxy(its radius, might never use it or penetrations) 
				{'application':Enums.StatusApplication.AOE,
				'effectType':Enums.StatusEffectType.SLOW,
				'strength':2,'duration':0.5},
				100,#AOE
				getAtlasAreaGrid(testingAtlas,22,10,64)),
			getAtlasAreaGrid(testingAtlas,20,8,64)
		),BlankTower.duplicate().setThisTowersValues(
			'BlueTower', Enums.TargetingTypes.CLOSEST,
			Enums.CanSeeCamo.CANNOTSEECAMO,
			0,200,0.5,5,# setMinRange,setMaxRange,setFireRate,setShopCost
			BlankBullet.setBulletValues(
				200,Enums.GuidanceTypes.SMART,
				0,Enums.Fuses.IMPACT,
				0, #fuse value, unused if not proxy(its radius, might never use it or penetrations) 
				{'application':Enums.StatusApplication.DIRECT,
				'effectType':Enums.StatusEffectType.DOT,
				'strength':2,'duration':10},
				0,#AOE
				getAtlasAreaGrid(testingAtlas,22,10,64)),
			getAtlasAreaGrid(testingAtlas,20,10,64)
		)
	]
	for i in Towers:
		UI.addShopItem(i)

	





	
	
	
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
