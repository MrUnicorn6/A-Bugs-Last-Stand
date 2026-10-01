extends Node
class_name GameplayObjectsLoader
#base objects:
const BASE_ENEMY_SCENE = preload("res://gameplay/enemies/enemy_base.tscn")
const BASE_TOWER_SCENE = preload("res://gameplay/towers/base_tower/base_tower.tscn")
const BASE_BULLET_SCENE = preload("res://gameplay/towers/base_tower/base_bullet.tscn")

#atlases
const TESTING_ATLAS = preload("res://assets/tower_defense_tilesheet.png")
const BUG_ATLAS = preload("res://assets/bug_atlas.png")

#enums
const Enums = preload("res://main/enums.gd")

#tower config split out into res://gameplay/towers/config/ (see tower_registry.gd)
const ConfigUtils = preload("res://gameplay/towers/config/config_utils.gd")
const TowerRegistry = preload("res://gameplay/towers/config/tower_registry.gd")

#paths, maybe useless due to not needing to save towers to disk

##static and hopefully constant/unchanging dict of all towers and their configs
## to get a specific tower, use towers_config["type"]["tower"]
##like towers_config["ants"]["bullet_ant"] returns: dict of configs
##the per tower data itself now lives in one file per bug family:
##  res://gameplay/towers/config/<Bug>/<bug>_towers.gd
##and is stitched together by res://gameplay/towers/config/tower_registry.gd
##this is only an alias,so main.gd / main_ui.gd keep working untouched
static var towers_config:Dictionary = TowerRegistry.towers_config

static func get_tower(key:String) ->Dictionary:
	
	for insect in towers_config.keys():
		for insect_kind in towers_config[insect].keys():
			print("looking for key ",key," opposed to ",insect_kind)
			if insect_kind == key:
				
				return towers_config[insect][insect_kind]
	
	print("WARNING TOWER ",key," NOT FOUND")
	return {}

static var enemies_config = {
	"fast":{
		"name":"fast",
		"health":10,
		"speed":200,
		"texture":get_atlas_texture(TESTING_ATLAS,15,10,64)
	},
	"strong":{
		"name":"strong",
		"health":30,
		"speed":50,
		"texture":get_atlas_texture(TESTING_ATLAS,16,10,64)
	},
	"boss":{
		"name":"boss",
		"health":50,
		"speed":50,
		"texture":get_atlas_texture(TESTING_ATLAS,17,10,64),
	},
	"camo":{
		"name":"camo",
		"health":30,
		"speed":50,
		"camo":true,
		"texture":get_atlas_texture(TESTING_ATLAS,18,10,64),
	},
	"fly":{
		"name":"fly",
		"health":10,
		"speed":300,
		"flying":true,#not implemented
		"texture":get_atlas_texture(TESTING_ATLAS,17,11,64),
		"resistances":"WAEWAKLKDNS"
	}
	
}

##checks towers_config for any invalid entries, and throws assertions if any are found
##NOT called automatically at startup yet:beetle, fire_ant and basic_bee still fail it
##(missing "class"/"bullet_config"/"upgrade_options_config_keys") - those gaps existed
##before the config files were split out and are being left as-is for now.
static func validate_towers_config():
	for clas in towers_config.keys():
		#the config file registered for this class must declare the same class_key
		if TowerRegistry.class_files.has(clas):
			assert(TowerRegistry.class_files[clas].class_key == clas,str("CLASS_KEY MISMATCH IN CONFIG FILE FOR ",clas))
		for tower_key in towers_config[clas]:
			var tower:Dictionary = towers_config[clas][tower_key]
			assert(!tower.is_empty(),str("EMPTY TOWER CONFIG FOR ",clas,"/",tower_key))
			assert(tower.has("class"),str("CLASS NOT FOUND IN CONFIG FOR ",clas," ",tower_key))
			assert(tower.has("bullet_config"),str("bullet not exists in ",clas," ",tower_key))
			assert(tower.has("upgrade_options_config_keys"),str("upgrade keys not defined for ",clas," ",tower_key))

			
			#validate upgrades
			


static func instance_tower(tower_config:Dictionary)->Object:
	var silly = BASE_TOWER_SCENE.instantiate()
	silly.set_config(tower_config)
	return silly
	
static func instance_enemy(enemy_config:Dictionary)->Object:
	var silly = BASE_ENEMY_SCENE.instantiate()
	silly.set_config(enemy_config)
	return silly


static func get_atlas_texture(atlas: Texture2D,col: int,row: int,cell_size) -> Texture2D:
	#single copy of this helper now lives in ConfigUtils,kept here so enemies_config
	#and anything else already calling Loader.get_atlas_texture() still works
	return ConfigUtils.get_atlas_texture(atlas,col,row,cell_size)
