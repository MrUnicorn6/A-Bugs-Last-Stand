extends Node2D
const BaseEnemy = preload("res://Enemies/EnemyBase.tscn")
const BlankTower = preload("res://Towers/BaseTower/Base_Tower.tscn")
const BlankBullet = preload("res://Towers/BaseTower/Base_Bullet.tscn")
@onready var UI = preload("res://UI/ui.tscn")
const testingAtlas = preload("res://Assets/towerDefense_tilesheet.png")
const BugAtlas = preload("res://Assets/BugAtlas.png")
@onready var map = preload("res://Maps/Map1/Map1.tscn")
const Enums = preload("res://Main/ENUMS.gd")
const TowerPath = "res://Towers/OtherTowers/"
const SpecialTowersPath = "res://Towers/PathUpgradeTowers/"
var currentMap
static var packedBasicTowers:Dictionary
static var packedSpecialTowers:Dictionary
static var packedEnemies:Dictionary

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#primary initiation stuff
	#packedTowers = load_scenes_in_folder("res://Towers/OtherTowers/")
	
	setAndGetEnemies()
	currentMap = map.instantiate()
	currentMap.setEnemies(packedEnemies)
	add_child(currentMap)
	
	UI = UI.instantiate()
	UI.mapObject = currentMap
	add_child(UI)
	SetAndSaveTowers()
	packedBasicTowers = load_scenes_in_folder(TowerPath)
	packedSpecialTowers = load_scenes_in_folder(SpecialTowersPath)
	for i in packedBasicTowers.keys():
		UI.addShopItem(packedBasicTowers[i])

#for loading sections of a atlas texture:
static func setAndGetEnemies():
	print("setting enemies")
	var Enemies = [BaseEnemy.instantiate().setEnemyValues({
			"name":"fast",
			"health":10,
			"speed":200,
			"texture":getAtlasAreaGrid(testingAtlas,15,10,64),
		}),
		BaseEnemy.instantiate().setEnemyValues({
			"name":"strong",
			"health":30,
			"speed":50,
			"texture":getAtlasAreaGrid(testingAtlas,16,10,64),
		}),
		BaseEnemy.instantiate().setEnemyValues({
			"name":"boss",
			"health":50,
			"speed":50,
			"texture":getAtlasAreaGrid(testingAtlas,17,10,64),
			"resistances":"WAEWAKLKDNS"
		}),
		BaseEnemy.instantiate().setEnemyValues({
			"name":"camo",
			"health":30,
			"speed":50,
			"camo":true,
			"texture":getAtlasAreaGrid(testingAtlas,18,10,64),
			"resistances":"WAEWAKLKDNS"
		}),
		BaseEnemy.instantiate().setEnemyValues({
			"name":"fly",
			"health":10,
			"speed":300,
			"flying":true,#not implemented
			"texture":getAtlasAreaGrid(testingAtlas,17,11,64),
			"resistances":"WAEWAKLKDNS"
		})
	]
	
	for i in Enemies:
		var scene = PackedScene.new()
		scene.pack(i)
		print("MAKING ENEMY WITH NAME ",i.displayName)
		packedEnemies[i.displayName] = scene

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
	var BaseTowers = [
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
				"cost":10,"desc":"faster firerate and can now see camo"},
				{
					"PathOne":{"Tower":"Fire Ant","cost":20,
						"desc":"Fire Ant, an ant focused on Fire & Fire DOT damage"},
					"PathTwo":{"Tower":"Bullet Ant","cost":20,
						"desc":"Bullet Ant, an ant focused on raw unguided firepower"},
					"PathThree":{"Tower":"Honey Ant","cost":20,
						"desc":"Honey ant, an ant focused on economics and buffing neaby towers "},
				}
				
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
				"cost":15,"desc":"better Damage, and slowness effect"},
				{
					"PathOne":{"Tower":"Scarab","cost":20,
						"desc":"blah"},
					"PathTwo":{"Tower":"Dung Beetle","cost":20,
						"desc":"poopy"},
					"PathThree":{"Tower":"Atlas","cost":20,
						"desc":"NOT IMPLEMENTED YET"},
				}
			]
		)
	]
	var SpecialTowers = [
		BlankTower.instantiate().setThisTowersValues(
			'Fire Ant', Enums.TargetingTypes.CLOSEST,
			Enums.CanSeeCamo.CANNOTSEECAMO,
			0,300,0.25,10,# setMinRange,setMaxRange,setFireRate,setShopCost
			prepareBullet([
				300,Enums.GuidanceTypes.SMART,
				5,Enums.Fuses.IMPACT,
				0, #fuse value, unused if not proxy(its radius, might never use it or penetrations) 
				{'application':Enums.StatusApplication.DIRECT,
				'effectType':Enums.StatusEffectType.DOT,
				'strength':4,'duration':4},
				0,#AOE
				getAtlasAreaGrid(testingAtlas,22,12,64)
			]),
			getAtlasAreaGrid(BugAtlas,5,2,32),
			[]
		),
		BlankTower.instantiate().setThisTowersValues(
			'Bullet Ant', Enums.TargetingTypes.LAST,
			Enums.CanSeeCamo.CANNOTSEECAMO,
			0,100,1,0,# setMinRange,setMaxRange,setFireRate,setShopCost
			prepareBullet([
				300,Enums.GuidanceTypes.DUMB,
				10,Enums.Fuses.TIMER,
				2, #fuse value, unused if not proxy(its radius, might never use it or penetrations) 
				null,
				0,#AOE
				getAtlasAreaGrid(testingAtlas,22,12,64)
			]),
			getAtlasAreaGrid(BugAtlas,8,2,32),
			[]
		),
		BlankTower.instantiate().setThisTowersValues(
			'Honey Ant', Enums.TargetingTypes.CLOSEST,
			Enums.CanSeeCamo.CANNOTSEECAMO,
			0,300,0.25,0,# setMinRange,setMaxRange,setFireRate,setShopCost
			prepareBullet([
				300,Enums.GuidanceTypes.SMART,
				1,Enums.Fuses.IMPACT,
				2, #fuse value, unused if not proxy(its radius, might never use it or penetrations) 
				{'application':Enums.StatusApplication.DIRECT,
				'effectType':Enums.StatusEffectType.SLOW,
				'strength':2,'duration':10},
				0,#AOE
				getAtlasAreaGrid(testingAtlas,22,12,64)
			]),
			getAtlasAreaGrid(BugAtlas,11,2,32),
			[]
		),
		BlankTower.instantiate().setThisTowersValues(
			'Scarab', Enums.TargetingTypes.LAST,
			Enums.CanSeeCamo.CANNOTSEECAMO,
			0,200,0.5,20,# setMinRange,setMaxRange,setFireRate,setShopCost
			prepareBullet([
				250,Enums.GuidanceTypes.DUMB,#bulletspeed
				5,Enums.Fuses.POINT, #damage
				1.5, #fuse value, unused if not proxy(its radius, might never use it or penetrations) 
				{'application':Enums.StatusApplication.AOE,
					'effectType':Enums.StatusEffectType.STUN,
					'strength':1,'duration':3}, #status object
				200,#AOE
				getAtlasAreaGrid(BugAtlas,2,9,32)
			]),
			getAtlasAreaGrid(BugAtlas,5,1,32),
			[]
		),
		BlankTower.instantiate().setThisTowersValues(
			'Dung Beetle', Enums.TargetingTypes.LAST,
			Enums.CanSeeCamo.CANNOTSEECAMO,
			0,200,0.5,20,# setMinRange,setMaxRange,setFireRate,setShopCost
			prepareBullet([
				250,Enums.GuidanceTypes.BALL,#bulletspeed
				5,Enums.Fuses.TIMER, #damage
				2, #fuse value, unused if not proxy(its radius, might never use it or penetrations) 
				{'application':Enums.StatusApplication.AOE,
					'effectType':Enums.StatusEffectType.STUN,
					'strength':1,'duration':2}, #status object
				64,#AOE
				getAtlasAreaGrid(BugAtlas,2,9,32)
			]),
			getAtlasAreaGrid(BugAtlas,8,1,32),
			[]
		),
		BlankTower.instantiate().setThisTowersValues(
			'Atlas', Enums.TargetingTypes.LAST,
			Enums.CanSeeCamo.CANNOTSEECAMO,
			0,200,0.5,20,# setMinRange,setMaxRange,setFireRate,setShopCost
			prepareBullet([
				250,Enums.GuidanceTypes.BALL,#bulletspeed
				5,Enums.Fuses.TIMEREXPLOSIVE, #damage
				2, #fuse value, unused if not proxy(its radius, might never use it or penetrations) 
				{'application':Enums.StatusApplication.AOE,
					'effectType':Enums.StatusEffectType.STUN,
					'strength':2,'duration':3}, #status object
				25,#AOE
				getAtlasAreaGrid(BugAtlas,2,9,32)
			]),
			getAtlasAreaGrid(BugAtlas,11,1,32),
			[]
		)
	]
	saveTowersToDisk(BaseTowers,TowerPath)
	saveTowersToDisk(SpecialTowers,SpecialTowersPath)
static func prepareBullet(bulletConfig)->PackedScene:
	#to procedurally create and config a bullet into a packed scene for use by the tower
	#does not save bullets to disk, this is mostly for reliable use of bullet.instantiate by shoot()
	
	var 	newBullet = BlankBullet.instantiate()
	newBullet.setBulletValuesViaConfigOBject(bulletConfig)
	var scene = PackedScene.new()
	scene.pack(newBullet)
	return scene
static func load_scenes_in_folder(path: String) -> Dictionary:
	var loaded_scenes: Dictionary= {}
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			# Ensure it is a file and has the .tscn extension
			if not dir.current_is_dir() and file_name.get_extension() == "tscn":
				# Construct the full path
				var full_path = path.path_join(file_name)
				#print("LOADING TOWER ",file_name.get_basename())
				var scene: PackedScene = load(full_path)
				if scene:
					loaded_scenes[file_name.get_basename()] = scene
			file_name = dir.get_next()
		dir.list_dir_end()
	else:
		print("An error occurred when trying to access the path: ", path)
	return loaded_scenes
static func saveTowersToDisk(towers,givenFilePath):
	for i in towers:
		var scene = PackedScene.new()
		var result = scene.pack(i)
		var path = str(givenFilePath,i.displayName,".tscn")
		if result == OK:
			var error = ResourceSaver.save(scene,path) 
			
			if error != OK:
				push_error("An error occurred while saving a scene to disk.")
static func getPackedSpecialTower(desiredTowerName)-> PackedScene:
	#print("LOOKING FOR TOWER ",desiredTowerName)
	for i in packedSpecialTowers.keys():
		if i == desiredTowerName:
			#print("FOUND TOWER ", i)
			return packedSpecialTowers[i]
	print("HEY TOWER",desiredTowerName,"NOT FOUND")
	return null
