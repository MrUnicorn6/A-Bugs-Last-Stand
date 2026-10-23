extends RefCounted
##Complete config for the strong enemy archetype.

const ConfigUtils = preload("res://gameplay/towers/config/config_utils.gd")
const TESTING_ATLAS = preload("res://assets/tower_defense_tilesheet.png")

static var config: Dictionary = {
	"name": "strong",
	"health": 30,
	"speed": 50,
	"bounty": 8,
	"leak_damage": 24,
	"texture": ConfigUtils.get_atlas_texture(TESTING_ATLAS, 16, 10, 64),
}
