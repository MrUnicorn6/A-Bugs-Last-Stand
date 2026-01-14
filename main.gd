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
	'''
	setMuzzleVelocity,setGuidance:Enums.GuidanceTypes,
		setDamageNumber,setFuseType:Enums.Fuses,setFuseValue,setStatusEffectData,
		setAOERadius,setSprite'''
	boomBullet.setBulletValues(
				300,
				Enums.GuidanceTypes.DUMB,
				0,#damage
				Enums.Fuses.TIMER,
				0, #fuse value, unused if not proxy(its radius, might never use it or penetrations) 
				{'application':Enums.StatusApplication.AOE,
				'effectType':Enums.StatusEffectType.SLOW,
				'strength':2,'duration':0.5},
				100,#AOE
				getAtlasAreaGrid(testingAtlas,22,10,64))
	
	redBullet.setBulletValues(
				200,
				Enums.GuidanceTypes.SMART,
				0,#damage
				Enums.Fuses.IMPACT,
				0, #fuse value, unused if not proxy(its radius, might never use it or penetrations) 
				{'application':Enums.StatusApplication.DIRECT,
				'effectType':Enums.StatusEffectType.DOT,
				'strength':2,'duration':10},
				0,#AOE
				getAtlasAreaGrid(testingAtlas,22,10,64))
	'''
	setName,setTargetingMethod:Enums.TargetingTypes,
		setCanSeeCamo:Enums.CanSeeCamo,
		setMinRange,setMaxRange,setFireRate,setShopCost,
		setBulletObject,setSprite
		'''
	redTower.setThisTowersValues(
			'BlueTower', Enums.TargetingTypes.CLOSEST,
			Enums.CanSeeCamo.CANNOTSEECAMO,
			0,200,0.5,5,# setMinRange,setMaxRange,setFireRate,setShopCost
			redBullet,
			getAtlasAreaGrid(testingAtlas,20,10,64))

	boomTower.setThisTowersValues(
			'BoomTower', Enums.TargetingTypes.CLOSEST,
			Enums.CanSeeCamo.CANNOTSEECAMO,
			10,600,0.25,10,# setMinRange,setMaxRange,setFireRate,setShopCost
			boomBullet,
			getAtlasAreaGrid(testingAtlas,20,8,64))
	UI.get_node("ShopManagementScripts").addShopItem(boomTower)

	UI.get_node("ShopManagementScripts").addShopItem(redTower)
	





	
	
	
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
