extends RefCounted
##every ant tower config,in one place.
##wired into Loader.towers_config["ants"] by res://Gameplay/Towers/Config/tower_registry.gd
##to look one up: towers["ant_two"]  (same as Loader.towers_config["ants"]["ant_two"])
##upgrades are still hand written:each tower lists the config keys it can upgrade
##into under "upgrade_options_config_keys",and those keys are looked up in this same file.

const Enums = preload("res://Main/ENUMS.gd")
const BUG_ATLAS = preload("res://Assets/BugAtlas.png")
const TESTING_ATLAS = preload("res://Assets/towerDefense_tilesheet.png")
const Utils = preload("res://Gameplay/Towers/Config/config_utils.gd")

##MUST match the key this file is registered under in tower_registry.gd,
##and the "class" string inside every tower below
static var class_key := "ants"

##static and hopefully constant/unchanging dict of all ant towers and their configs
static var towers = {
	"ant":{
		"icon_texture":Utils.get_atlas_texture(BUG_ATLAS,1,2,32),
		"tower_texture":Utils.get_atlas_texture(BUG_ATLAS,2,2,32),
		"display_name":"ant",
		"class":"ants", #MUST MATCH ABOVE CLASS NAME( like ants, beeltes, bees ect), used to find other upgraded ants ect..
		"desc":"mid range",
		"targeting":Enums.TargetingTypes.FIRST,
		"can_see_camo":Enums.CanSeeCamo.CANNOTSEECAMO,
		"min_range":0,
		"max_range":300,
		"fire_rate":1,##expressed in delay between shots in seconds
		"shop_cost":5,
		"bullet_config":{
			"bullet_texture":Utils.get_atlas_texture(TESTING_ATLAS,22,10,64),
			"speed":300,##in pixles per second
			"guidance":Enums.GuidanceTypes.SMART,
			"direct_damage":5,#to whatever it hits, usually its intended target
			"fuse":Enums.Fuses.IMPACT,
		},
		"upgrade_options_config_keys":[
			"ant_two"
		]
	},
	"ant_two":{
		"tower_texture":Utils.get_atlas_texture(BUG_ATLAS,3,2,32),
		"display_name":"ant but better",
		"class":"ants",
		"desc":"better ant range and damage",
		"targeting":Enums.TargetingTypes.FIRST,
		"can_see_camo":Enums.CanSeeCamo.CANNOTSEECAMO,
		"min_range":0,
		"max_range":400,
		"fire_rate":1,##expressed in delay between shots in seconds
		"shop_cost":5,
		"bullet_config":{
			"bullet_texture":Utils.get_atlas_texture(TESTING_ATLAS,22,10,64),
			"speed":350,##in pixles per second
			"guidance":Enums.GuidanceTypes.SMART,
			"direct_damage":7,#to whatever it hits, usually its intended target
			"fuse":Enums.Fuses.IMPACT,
		},
		"upgrade_options_config_keys":[
			"ant_three",
			"fire_ant"
		]
	},
	"ant_three":{
		"tower_texture":Utils.get_atlas_texture(BUG_ATLAS,4,2,32),
		"display_name":"ant but even better",
		"class":"ants",
		"desc":"can now see camo, and better firerate",
		"targeting":Enums.TargetingTypes.FIRST,
		"can_see_camo":Enums.CanSeeCamo.CANSEECAMO,
		"min_range":0,
		"max_range":400,
		"fire_rate":0.75,##expressed in delay between shots in seconds
		"shop_cost":5,
		"bullet_config":{
			"bullet_texture":Utils.get_atlas_texture(TESTING_ATLAS,22,10,64),
			"speed":350,##in pixles per second
			"guidance":Enums.GuidanceTypes.SMART,
			"direct_damage":10,#to whatever it hits, usually its intended target
			"fuse":Enums.Fuses.IMPACT,
		},
		"upgrade_options_config_keys":[
			"ant_three"
		]
	},

	"fire_ant":{
		"display_name":"fire ant",
		"class":"ants",
		"desc":"burn range",
		"targeting":Enums.TargetingTypes.CLOSEST,
		"can_see_camo":Enums.CanSeeCamo.CANNOTSEECAMO,
		"min_range":0,
		"max_range":300,
		"fire_rate":0.25,##expressed in delay between shots in seconds
		"shop_cost":10,
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
		"tower_texture":Utils.get_atlas_texture(BUG_ATLAS,2,2,32),
		"upgrade_options_config_keys":[] #no further upgrades yet (used to be "upgrades":null)
	}
}
