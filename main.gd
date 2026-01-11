extends Node2D
@onready var Path = preload("res://Maps/BaseMapPath.tscn")
@onready var BaseEnemy = preload("res://Enemies/EnemyBase.tscn")
@onready var BaseTower = preload("res://SourceTowers/BaseTower/Base_Tower.tscn")
@onready var BaseBullet = preload("res://SourceTowers/BaseTower/Base_Bullet.tscn")

const TargetingEnums = preload(
    "res://SourceTowers/BaseTower/TowerResources/TargetingAndGuidanceMethods.gd"
)

var testingAtlas = load("res://Assets/towerDefense_tilesheet.png")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#primary initiation stuff
	
	#creation of all towers
	print("CREATING TOWERS")
	BaseTower = BaseTower.instantiate()
	BaseBullet = BaseBullet.instantiate()
	var tempProjectiles = {
		'regularBullet':BaseBullet.createNewBulletType(BaseBullet,200,TargetingEnums.TowerGuideOrTargetingEnums.GuidanceTypes.DUMB, 5,getAtlasAreaGrid(testingAtlas,26,10,64))
	}
	var AllTowers = {
		'redTower':BaseTower.createNewTowerType(
			BaseTower,#all towers require a base
			5,0,20,1,5,# setMinRange,setMaxRange,setFireRate,setShopCost
			null,
			getAtlasAreaGrid(testingAtlas,26,9,64))
		,'boomTower':null
		}
	print("STUFF ",AllTowers["redTower"].bulletDamage)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_spawn_timer_timeout() -> void:
	var Enemy1 = Path.instantiate()
	
	
	
#for loading sections of a atlas texture:
static func getAtlasAreaGrid(atlas: Texture2D,col: int,row: int,cell_size) -> AtlasTexture:  
	var tex := AtlasTexture.new()
	tex.atlas = atlas
	tex.region = Rect2(
		col * cell_size,
		row * cell_size,
		cell_size,
		cell_size)
	return tex
