extends RefCounted
##Complete config for the fly enemy archetype.

const ConfigUtils = preload("res://gameplay/towers/config/config_utils.gd")
const GameplayObject = preload("res://gameplay/gameplay_object.gd")
const TESTING_ATLAS = preload("res://assets/tower_defense_tilesheet.png")

static var config: Dictionary = {
	"name": "fly",
	"health": 10,
	"speed": 300,
	"movement_profile": GameplayObject.MovementProfile.FLYING,
	"navigation_layers": 3,
	"bounty": 6,
	"leak_damage": 24,
	"texture": ConfigUtils.get_atlas_texture(TESTING_ATLAS, 17, 11, 64),
	"resistances": "WAEWAKLKDNS",
}
