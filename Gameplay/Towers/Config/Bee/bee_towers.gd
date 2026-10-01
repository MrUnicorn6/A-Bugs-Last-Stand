extends RefCounted
##every bee tower config,in one place.
##wired into Loader.towers_config["bees"] by res://Gameplay/Towers/Config/tower_registry.gd
##to look one up: towers["basic_bee"]  (same as Loader.towers_config["bees"]["basic_bee"])
##careful: this tower is an empty stub,as it was in the old gameplay_objects_loader.gd.

const Enums = preload("res://Main/enums.gd")
const BUG_ATLAS = preload("res://Assets/BugAtlas.png")
const TESTING_ATLAS = preload("res://Assets/towerDefense_tilesheet.png")
const Utils = preload("res://Gameplay/Towers/Config/config_utils.gd")

##MUST match the key this file is registered under in tower_registry.gd,
##and the "class" string inside every tower below
static var class_key := "bees"

##static and hopefully constant/unchanging dict of all bee towers and their configs
static var towers = {
	"basic_bee":{
		#DRONES SOON???
		"upgrade_options_config_keys":[]
	}
}
