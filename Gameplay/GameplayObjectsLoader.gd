extends Node
#blank objects:
const BaseEnemy = preload("res://Gameplay/Enemies/EnemyBase.tscn")
const BlankTower = preload("res://Gameplay/Towers/BaseTower/Depr_base_TOWER.tscn")
const BlankBullet = preload("res://Gameplay/Towers/BaseTower/base_bullet.tscn")

#atlases
const TestingAtlas = preload("res://Assets/towerDefense_tilesheet.png")
const BugAtlas = preload("res://Assets/BugAtlas.png")

#enums
const Enums = preload("res://Main/ENUMS.gd")

#paths, maybe useless due to not needing to save towers to disk
const SpecialTowersPath = "res://Towers/PathUpgradeTowers/"
const TowersPath = "res://"
##static and hopefully constant/unchanging array of all towers and their configs
## to get a specific tower, use towers_config["type"]["tower"]
##like towers_config["ants"]["bullet_ant"] returns: dict of configs
static var towers_config = {
	"ants":{
		"ant":{
			"display_name":"ant",
			"desc":"mid range",
			"icon_texture":get_atlas_texture(BugAtlas,1,2,32),
			"targeting":Enums.TargetingTypes.FIRST,
			"can_see_camo":Enums.CanSeeCamo.CANNOTSEECAMO,
			"min_range":0,
			"max_range":300,
			"fire_rate":1,##expressed in delay between shots in seconds
			"shop_cost":5,
			"bullet_config":{
				"bullet_texture":get_atlas_texture(TestingAtlas,22,10,64),
				"speed":300,##in pixles per second
				"guidance":Enums.GuidanceTypes.DUMB,
				"aoe_radius":100,
				"direct_damage":5,#to whatever it hits, usually its intended target
				"fuse":Enums.Fuses.POINT,
				"aoe_damage":10
				
			},
			"tower_texture":get_atlas_texture(BugAtlas,2,2,32),
			#"upgrades":null #unsure how to do this yet
		},
		"fire_ant":{
			"display_name":"fire ant",
			"desc":"burn range",
			"targeting":Enums.TargetingTypes.CLOSEST,
			"can_see_camo":Enums.CanSeeCamo.CANNOTSEECAMO,
			"min_range":0,
			"max_range":300,
			"fire_rate":0.25,##expressed in delay between shots in seconds
			"upgrade_cost":10,
			"bullet_config":{
				"speed":300,##in pixles per second
				"guidance":Enums.GuidanceTypes.SMART,
				"direct_damage":5,#to whatever it hits, usually its intended target
				"fuse":Enums.Fuses.IMPACT, # may not be needed for this ant
				"status_effect":{
					"status_application":Enums.StatusApplication.DIRECT,
					"status_type":Enums.StatusEffectType.DOT,
					"status_duration":4,
					"status_strength":4
				}
			},
			"tower_texture":get_atlas_texture(BugAtlas,2,2,32),
			"upgrades":null #unsure how to do this yet
		}
	},
	"beetles":{
		"beetle":{
			"icon_texture":get_atlas_texture(BugAtlas,1,1,32),
			"display_name":"beelte",
			"desc":"ball ball ball",
			"targeting":Enums.TargetingTypes.LAST,
			"can_see_camo":Enums.CanSeeCamo.CANNOTSEECAMO,
			"min_range":0,
			"max_range":200,
			"fire_rate":0.25,##expressed in delay between shots in seconds
			"shop_cost":10,
			"bullet_config":{
				"speed":250,
				"guidance":Enums.GuidanceTypes.BALL,#bulletspeed
				"fuse":Enums.Fuses.TIMER,
				"fuse_value":1,
				"damage":5,
				"aoe_radius":32,
				"bullet_texture":get_atlas_texture(BugAtlas,2,9,32)
			},
			"tower_texture":get_atlas_texture(BugAtlas,2,1,32),
		}
	},
	"bees":{
		"basic_bee":{
			#DRONES SOON???	
		}
	}
}
"""
static var BasicTowers = [
	BlankTower.instantiate().setThisTowersValues(
		'Ant', Enums.TargetingTypes.FIRST,
		Enums.CanSeeCamo.CANNOTSEECAMO,
		0,300,1,5,# setMinRange,setMaxRange,setFireRate,setShopCost
		prepareBullet([
			251,Enums.GuidanceTypes.SMART,#bulletspeed
			5,Enums.Fuses.IMPACT, #damage
			0, #fuse value, unused if not proxy(its radius, might never use it or penetrations) 
			null, #status object
			0,#AOE
			getAtlasAreaTexture(TestingAtlas,22,10,64)
		]),
		getAtlasAreaTexture(BugAtlas,2,2,32),
		[#upgrades, should be 2 per tower
			{"range":100,"damage":20,"muzzleVelocity":50,"sprite":getAtlasAreaTexture(BugAtlas,3,2,32),
			"cost":10,"desc":"better dmg, bullet speed and range"},
			{"firerate":0.5,"canseecamo":Enums.CanSeeCamo.CANSEECAMO,"sprite":getAtlasAreaTexture(BugAtlas,4,2,32),
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
			getAtlasAreaTexture(BugAtlas,2,9,32)
		]),
		getAtlasAreaTexture(BugAtlas,2,1,32),
		[{"firerate":0.5,"aoeradius":16,"fusevalue":1,"sprite":getAtlasAreaTexture(BugAtlas,3,1,32),
			"cost":10,"desc":"better firerate, ball Radius,and ball distance"},
			{"damage":5,"status":
				{'application':Enums.StatusApplication.DIRECT,
				'effectType':Enums.StatusEffectType.SLOW,
				'strength':2,'duration':3}
				,"sprite":getAtlasAreaTexture(BugAtlas,4,1,32),
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
static var SpecialTowers = [
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
			getAtlasAreaTexture(TestingAtlas,22,12,64)
		]),
		getAtlasAreaTexture(BugAtlas,5,2,32),
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
			getAtlasAreaTexture(TestingAtlas,22,12,64)
		]),
		getAtlasAreaTexture(BugAtlas,8,2,32),
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
			getAtlasAreaTexture(TestingAtlas,22,12,64)
		]),
		getAtlasAreaTexture(BugAtlas,11,2,32),
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
			getAtlasAreaTexture(BugAtlas,2,9,32)
		]),
		getAtlasAreaTexture(BugAtlas,5,1,32),
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
			getAtlasAreaTexture(BugAtlas,2,9,32)
		]),
		getAtlasAreaTexture(BugAtlas,8,1,32),
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
			getAtlasAreaTexture(BugAtlas,2,9,32)
		]),
		getAtlasAreaTexture(BugAtlas,11,1,32),
		[]
	)
]
"""
static var Enemies = [
	BaseEnemy.instantiate().setEnemyValues({
		"name":"fast",
		"health":10,
		"speed":200,
		"texture":get_atlas_texture(TestingAtlas,15,10,64),
	}),
	BaseEnemy.instantiate().setEnemyValues({
		"name":"strong",
		"health":30,
		"speed":50,
		"texture":get_atlas_texture(TestingAtlas,16,10,64),
	}),
	BaseEnemy.instantiate().setEnemyValues({
		"name":"boss",
		"health":50,
		"speed":50,
		"texture":get_atlas_texture(TestingAtlas,17,10,64),
		"resistances":"WAEWAKLKDNS"
	}),
	BaseEnemy.instantiate().setEnemyValues({
		"name":"camo",
		"health":30,
		"speed":50,
		"camo":true,
		"texture":get_atlas_texture(TestingAtlas,18,10,64),
		"resistances":"WAEWAKLKDNS"
	}),
	BaseEnemy.instantiate().setEnemyValues({
		"name":"fly",
		"health":10,
		"speed":300,
		"flying":true,#not implemented
		"texture":get_atlas_texture(TestingAtlas,17,11,64),
		"resistances":"WAEWAKLKDNS"
	})
]
"""
static func getPackedBasicTowers() ->Dictionary:
	return pack(BasicTowers)
static func getPackedSpecialTowers()-> Dictionary:
	return pack(SpecialTowers)"""
static func getPackedEnemies()->Dictionary:
	return pack(Enemies)
	

static func pack(objects)->Dictionary:
	var toSend = {}
	for i in objects:
		var scene = PackedScene.new()
		scene.pack(i)
		toSend[i.displayName]=scene
	return toSend

static func get_atlas_texture(atlas: Texture2D,col: int,row: int,cell_size) -> Texture2D:  
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
static func prepareBullet(bulletConfig)->PackedScene:
	#to procedurally create and config a bullet into a packed scene for use by the tower
	#does not save bullets to disk, this is mostly for reliable use of bullet.instantiate by shoot()
	return null
	"""
	var 	newBullet = BlankBullet.instantiate()
	newBullet.setBulletValuesViaConfigOBject(bulletConfig)
	var scene = PackedScene.new()
	scene.pack(newBullet)
	return scene
	"""
