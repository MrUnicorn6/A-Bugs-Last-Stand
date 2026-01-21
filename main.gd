extends Node2D
@onready var Path = preload("res://Maps/BaseMapPath.tscn")
@onready var BaseEnemy = preload("res://Enemies/EnemyBase.tscn")
const BlankTower = preload("res://Towers/BaseTower/Base_Tower.tscn")
const BlankBullet = preload("res://Towers/BaseTower/Base_Bullet.tscn")
#@onready var shopUI = preload("res://UI/shop_management_scripts.gd")
@onready var UI = preload("res://UI/ui.tscn")
const testingAtlas = preload("res://Assets/towerDefense_tilesheet.png")
const BugAtlas = preload("res://Assets/BugAtlas.png")
@onready var map = preload("res://Maps/Map1/Map1.tscn")
const Enums = preload("res://Main/ENUMS.gd")
var currentMap
var packedTowers

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#primary initiation stuff
	#packedTowers = load_scenes_in_folder("res://Towers/OtherTowers/")
	currentMap = map.instantiate()
	currentMap.z_index = -10
	add_child(currentMap)
	
	UI = UI.instantiate()
	UI.mapObject = currentMap
	add_child(UI)
	SetAndSaveTowers()
	packedTowers = load_scenes_in_folder("res://Towers/OtherTowers/")
	for i in packedTowers:
		UI.addShopItem(i)
	

	





	
	
	
#for loading sections of a atlas texture:
static func getAtlasAreaGrid(atlas: Texture2D,col: int,row: int,cell_size) -> Texture2D:  
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
	
	
static func SetAndSaveTowers():
	#setting of all towers
	var UnpackedTowers = [
		BlankTower.instantiate().setThisTowersValues(
			'Ant', Enums.TargetingTypes.FIRST,
			Enums.CanSeeCamo.CANNOTSEECAMO,
			0,300,1,5,# setMinRange,setMaxRange,setFireRate,setShopCost
			prepareBullet([
				200,Enums.GuidanceTypes.SMART,#bulletspeed
				5,Enums.Fuses.IMPACT, #damage
				0, #fuse value, unused if not proxy(its radius, might never use it or penetrations) 
				null, #status object
				0,#AOE
				getAtlasAreaGrid(testingAtlas,22,10,64)
			]),
			getAtlasAreaGrid(BugAtlas,2,2,32),
			[#upgrades, should be 2 per tower
				{"range":100,"damage":20,"sprite":getAtlasAreaGrid(BugAtlas,3,2,32),
				"cost":10,"desc":"better dmg and range"},
				{"firerate":0.5,"canseecamo":Enums.CanSeeCamo.CANSEECAMO,"sprite":getAtlasAreaGrid(BugAtlas,4,2,32),
				"cost":10,"desc":"faster firerate and can now see camo"}
			]
		),
		BlankTower.instantiate().setThisTowersValues(
			'Beetle', Enums.TargetingTypes.LAST,
			Enums.CanSeeCamo.CANNOTSEECAMO,
			0,200,0.25,10,# setMinRange,setMaxRange,setFireRate,setShopCost
			prepareBullet([
				250,Enums.GuidanceTypes.BALL,#bulletspeed
				5,Enums.Fuses.TIMER, #damage
				1, #fuse value, unused if not proxy(its radius, might never use it or penetrations) 
				null, #status object
				32,#AOE
				getAtlasAreaGrid(BugAtlas,2,9,32)
			]),
			getAtlasAreaGrid(BugAtlas,2,1,32),
			[{"firerate":0.5,"aoeradius":16,"fusevalue":1,"sprite":getAtlasAreaGrid(BugAtlas,3,1,32),
				"cost":10,"desc":"better firerate, ball Radius,and ball distance"},
				{"damage":5,"status":
					{'application':Enums.StatusApplication.DIRECT,
					'effectType':Enums.StatusEffectType.SLOW,
					'strength':2,'duration':3}
					,"sprite":getAtlasAreaGrid(BugAtlas,4,1,32),
				"cost":15,"desc":"better Damage, and slowness effect"}]
		),
		BlankTower.instantiate().setThisTowersValues(
			'BoomTower', Enums.TargetingTypes.CLOSEST,
			Enums.CanSeeCamo.CANNOTSEECAMO,
			10,600,0.25,10,# setMinRange,setMaxRange,setFireRate,setShopCost
			prepareBullet([
				300,Enums.GuidanceTypes.DUMB,
				0,Enums.Fuses.POINT,0, #fuse value, unused if not proxy(its radius, might never use it or penetrations) 
				{'application':Enums.StatusApplication.AOE,
				'effectType':Enums.StatusEffectType.SLOW,
				'strength':2,'duration':0.5},
				100,#AOE
				getAtlasAreaGrid(testingAtlas,22,10,64)
			]),
			getAtlasAreaGrid(testingAtlas,20,8,64),
			[]
		),BlankTower.instantiate().setThisTowersValues(
			'BlueTower', Enums.TargetingTypes.CLOSEST,
			Enums.CanSeeCamo.CANNOTSEECAMO,
			0,200,0.5,5,# setMinRange,setMaxRange,setFireRate,setShopCost
			prepareBullet([
				200,Enums.GuidanceTypes.SMART,
				0,Enums.Fuses.IMPACT,
				0, #fuse value, unused if not proxy(its radius, might never use it or penetrations) 
				{'application':Enums.StatusApplication.DIRECT,
				'effectType':Enums.StatusEffectType.DOT,
				'strength':2,'duration':10},
				0,#AOE
				getAtlasAreaGrid(testingAtlas,22,10,64)
			]),
			getAtlasAreaGrid(testingAtlas,20,10,64),
			[]
		)
	]
	
	saveTowersToDisk(UnpackedTowers)
	
static func prepareBullet(bulletConfig)->PackedScene:
	#to procedurally create and config a bullet into a packed scene for use by the tower
	#does not save bullets to disk, this is mostly for reliable use of bullet.instantiate by shoot()
	var 	newBullet = BlankBullet.instantiate()
	newBullet.setBulletValuesViaConfigOBject(bulletConfig)
	var scene = PackedScene.new()
	scene.pack(newBullet)
	return scene
static func load_scenes_in_folder(path: String) -> Array[PackedScene]:
	var loaded_scenes: Array[PackedScene] = []
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			# Ensure it is a file and has the .tscn extension
			if not dir.current_is_dir() and file_name.get_extension() == "tscn":
				# Construct the full path
				var full_path = path.path_join(file_name)
				#print("LOADING TOWER ",file_name)
				# Use load() to get the resource at runtime
				var scene: PackedScene = load(full_path)
				if scene:
					loaded_scenes.append(scene)
			file_name = dir.get_next()
		dir.list_dir_end()
	else:
		print("An error occurred when trying to access the path: ", path)
	return loaded_scenes
static func saveTowersToDisk(towers):
	for i in towers:
		var scene = PackedScene.new()
		var result = scene.pack(i)
		var path = str("res://Towers/OtherTowers/",i.displayName,".tscn")
		if result == OK:
			var error = ResourceSaver.save(scene,path) 
			
			if error != OK:
				push_error("An error occurred while saving a scene to disk.")
