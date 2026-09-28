extends RefCounted
##every beetle tower config,in one place.
##wired into loader.towers_config["beetles"] by res://Gameplay/Towers/Config/tower_registry.gd
##to look one up: towers["beetle"]  (same as loader.towers_config["beetles"]["beetle"])
##NOTE: this entry is still missing "class" exactly as it was before the config
##files were split out,so it is left alone for now - but it does have an empty
##upgrade_options_config_keys,so its upgrade panel opens with no options instead of erroring.

const Enums = preload("res://Main/ENUMS.gd")
const BugAtlas = preload("res://Assets/BugAtlas.png")
const Utils = preload("res://Gameplay/Towers/Config/config_utils.gd")

##MUST match the key this file is registered under in tower_registry.gd,
##and the "class" string inside every tower below
static var class_key := "beetles"

##static and hopefully constant/unchanging dict of all beetle towers and their configs
static var towers = {
	"beetle":{
		"icon_texture":Utils.get_atlas_texture(BugAtlas,1,1,32),
		"display_name":"beelte",
		"desc":"ball ball ball",
		"targeting":Enums.TargetingTypes.FIRST,
		"can_see_camo":Enums.CanSeeCamo.CANNOTSEECAMO,
		"min_range":0,
		"max_range":200,
		"fire_rate":0.25,##expressed in delay between shots in seconds
		"shop_cost":10,
		"bullet_config":{
			"speed":150,
			"guidance":Enums.GuidanceTypes.BALL,#bulletspeed
			"fuse":Enums.Fuses.TIMER,
			"fuse_value":2,
			"direct_damage":5,
			"aoe_radius":60,
			"bullet_texture":Utils.get_atlas_texture(BugAtlas,2,9,32)
		},
		"tower_texture":Utils.get_atlas_texture(BugAtlas,2,1,32),
		"upgrade_options_config_keys":[] #no upgrades defined yet
	}
}
