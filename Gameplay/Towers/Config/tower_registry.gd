extends RefCounted
##stitches the per-bug tower config files into the single towers_config dict
##that the rest of the game reads through Loader.towers_config.
##
##to add a new bug family:
## 1. make res://Gameplay/Towers/Config/<Bug>/<bug>_towers.gd with a `towers` dict
## 2. preload it below and add one line to class_files and one to towers_config

const AntTowers = preload("res://Gameplay/Towers/Config/Ant/ant_towers.gd")
const BeetleTowers = preload("res://Gameplay/Towers/Config/Beetle/beetle_towers.gd")
const BeeTowers = preload("res://Gameplay/Towers/Config/Bee/bee_towers.gd")

##class key -> config file script,so validation can cross check every file
##really is registered under its own class_key
static var class_files:Dictionary = {
	"ants":AntTowers,
	"beetles":BeetleTowers,
	"bees":BeeTowers,
}

##same shape towers_config has always had:towers_config["ants"]["ant"] -> tower config dict
static var towers_config:Dictionary = {
	"ants":AntTowers.towers,
	"beetles":BeetleTowers.towers,
	"bees":BeeTowers.towers,
}

##convenience lookup that returns {} instead of erroring when the key is wrong
static func get_tower(class_key:String,tower_key:String)->Dictionary:
	if !towers_config.has(class_key):
		return {}
	if !towers_config[class_key].has(tower_key):
		return {}
	return towers_config[class_key][tower_key]
