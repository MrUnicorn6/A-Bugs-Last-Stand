extends RefCounted
##Complete config for the boss enemy archetype.

const ConfigUtils = preload("res://gameplay/towers/config/config_utils.gd")
const TESTING_ATLAS = preload("res://assets/tower_defense_tilesheet.png")

static var config: Dictionary = {
	"name": "boss",
	"health": 50,
	"speed": 50,
	"bounty": 60,
	"leak_damage": 24,
	"texture": ConfigUtils.get_atlas_texture(TESTING_ATLAS, 17, 10, 64),
}
