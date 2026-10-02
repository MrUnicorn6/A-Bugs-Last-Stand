extends RefCounted
##every beetle tower config,in one place.
##wired into Loader.towers_config["beetles"] by res://gameplay/towers/config/tower_registry.gd
##to look one up: towers["beetle"]  (same as Loader.towers_config["beetles"]["beetle"])
##NOTE: this entry is still missing "class" exactly as it was before the config
##files were split out,so it is left alone for now - but it does have an empty
##upgrade_options_config_keys,so its upgrade panel opens with no options instead of erroring.

const Enums = preload("res://main/enums.gd")
const BUG_ATLAS = preload("res://assets/bug_atlas.png")
const Utils = preload("res://gameplay/towers/config/config_utils.gd")

##MUST match the key this file is registered under in tower_registry.gd,
##and the "class" string inside every tower below
static var class_key := "beetles"

##static and hopefully constant/unchanging dict of all beetle towers and their configs
static var towers = {
	"beetle":{
		"icon_texture":Utils.get_atlas_texture(BUG_ATLAS,1,1,32),
		"display_name":"Beelte",
		"desc":"ball ball ball",
		"targeting":Enums.TargetingType.FIRST,
		"can_see_camo":Enums.CanSeeCamo.CANNOT_SEE_CAMO,
		"min_range":0,
		"max_range":200,
		"fire_rate":0.25,##expressed in delay between shots in seconds
		"shop_cost":10,
		"bullet_config":{
			"speed":150,
			"guidance":Enums.GuidanceType.BALL,#bulletspeed
			"fuse":Enums.Fuse.TIMER,
			"fuse_value":2,
			"direct_damage":5,
			"aoe_radius":60,
			"bullet_texture":Utils.get_atlas_texture(BUG_ATLAS,2,9,32)
		},
		"tower_texture":Utils.get_atlas_texture(BUG_ATLAS,2,1,32),
		"upgrade_options_config_keys":[
			"beetle_two"
		] #no upgrades defined yet
	},
	"beetle_two":{
		"icon_texture":Utils.get_atlas_texture(BUG_ATLAS,1,1,32),
		"display_name":"Beetle Two",
		"desc":"Longer Range, targets closest",
		"targeting":Enums.TargetingType.CLOSEST,
		"can_see_camo":Enums.CanSeeCamo.CANNOT_SEE_CAMO,
		"min_range":0,
		"max_range":300,
		"fire_rate":0.25,##expressed in delay between shots in seconds
		"shop_cost":10,
		"bullet_config":{
			"speed":175,
			"guidance":Enums.GuidanceType.BALL,#bulletspeed
			"fuse":Enums.Fuse.TIMER,
			"fuse_value":2,
			"direct_damage":5,
			"aoe_radius":60,
			"bullet_texture":Utils.get_atlas_texture(BUG_ATLAS,2,9,32)
		},
		"tower_texture":Utils.get_atlas_texture(BUG_ATLAS,3,1,32),
		"upgrade_options_config_keys":[
			"beetle_three"
		] #no upgrades defined yet
	},
	"beetle_three":{
		"icon_texture":Utils.get_atlas_texture(BUG_ATLAS,1,1,32),
		"display_name":"Beetle Three",
		"desc":"Longer Range, targets closest",
		"targeting":Enums.TargetingType.CLOSEST,
		"can_see_camo":Enums.CanSeeCamo.CANNOT_SEE_CAMO,
		"min_range":0,
		"max_range":300,
		"fire_rate":0.25,##expressed in delay between shots in seconds
		"shop_cost":20,
		"bullet_config":{
			"speed":200,
			"guidance":Enums.GuidanceType.BALL,#bulletspeed
			"fuse":Enums.Fuse.TIMER,
			"fuse_value":3,
			"direct_damage":10,
			"aoe_radius":60,
			"bullet_texture":Utils.get_atlas_texture(BUG_ATLAS,2,9,32)
		},
		"tower_texture":Utils.get_atlas_texture(BUG_ATLAS,4,1,32),
		"upgrade_options_config_keys":[
			"horn_beetle",
			"scarab_one",
			"dung_beetle"
			
		] #no upgrades defined yet
	},
	"scarab_one":{
		"icon_texture":Utils.get_atlas_texture(BUG_ATLAS,1,1,32),
		"display_name":"Scarab",
		"desc":"I forgor what the scarabs gimmic is",
		"targeting":Enums.TargetingType.CLOSEST,
		"can_see_camo":Enums.CanSeeCamo.CANNOT_SEE_CAMO,
		"min_range":0,
		"max_range":300,
		"fire_rate":0.25,##expressed in delay between shots in seconds
		"shop_cost":20,
		"bullet_config":{
			"speed":200,
			"guidance":Enums.GuidanceType.BALL,#bulletspeed
			"fuse":Enums.Fuse.TIMER,
			"fuse_value":3,
			"direct_damage":10,
			"aoe_radius":60,
			"bullet_texture":Utils.get_atlas_texture(BUG_ATLAS,2,9,32)
		},
		"tower_texture":Utils.get_atlas_texture(BUG_ATLAS,5,1,32),
		"upgrade_options_config_keys":[] #no upgrades defined yet
	},
	"dung_beetle":{
		"icon_texture":Utils.get_atlas_texture(BUG_ATLAS,1,1,32),
		"display_name":"STINKY",
		"desc":"I forgor what the dung beetles gimmic is",
		"targeting":Enums.TargetingType.CLOSEST,
		"can_see_camo":Enums.CanSeeCamo.CANNOT_SEE_CAMO,
		"min_range":0,
		"max_range":300,
		"fire_rate":0.25,##expressed in delay between shots in seconds
		"shop_cost":20,
		"bullet_config":{
			"speed":200,
			"guidance":Enums.GuidanceType.BALL,#bulletspeed
			"fuse":Enums.Fuse.TIMER,
			"fuse_value":3,
			"direct_damage":7,
			"aoe_radius":60,
			"bullet_texture":Utils.get_atlas_texture(BUG_ATLAS,2,9,32),
			"status_effect":{
				"status_application":Enums.StatusApplication.DIRECT,
				"status_type":Enums.StatusEffectType.SLOW,
				"status_duration":4,
				"status_strength":2
			}
		},
		"tower_texture":Utils.get_atlas_texture(BUG_ATLAS,8,1,32),
		"upgrade_options_config_keys":[] #no upgrades defined yet
	},
	"horn_beetle":{
		"icon_texture":Utils.get_atlas_texture(BUG_ATLAS,1,1,32),
		"display_name":"YEET",
		"desc":"YEET",
		"targeting":Enums.TargetingType.CLOSEST,
		"can_see_camo":Enums.CanSeeCamo.CANNOT_SEE_CAMO,
		"min_range":0,
		"max_range":300,
		"fire_rate":0.25,##expressed in delay between shots in seconds
		"shop_cost":20,
		"bullet_config":{
			"speed":200,
			"guidance":Enums.GuidanceType.BALL,#bulletspeed
			"fuse":Enums.Fuse.TIMER,
			"fuse_value":3,
			"direct_damage":10,
			"aoe_radius":60,
			"bullet_texture":Utils.get_atlas_texture(BUG_ATLAS,2,9,32)
		},
		"tower_texture":Utils.get_atlas_texture(BUG_ATLAS,8,1,32),
		"upgrade_options_config_keys":[] #no upgrades defined yet
	}
}
