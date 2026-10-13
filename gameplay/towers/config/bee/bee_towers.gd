extends RefCounted
##bee family: same 12-slot delta tree as ant / BLANK.
##old key basic_bee is now bee_tower. Loader.towers_config["bees"]["bee_tower"]
##bee is meant to fly at global range; BaseTower is still a StaticBody2D, so
##range is just a large number until a flyer archetype exists.

const Enums = preload("res://main/enums.gd")
const Utils = preload("res://gameplay/towers/config/config_utils.gd")

const SHEET = preload("res://gameplay/towers/config/bee/bee_art.png")
const INSECT := "bee"
const CLASS := "bees"

static var class_key := CLASS

const sprites := {
	"cell": 32,
	"icon": {"type": "sprite", "col": 1, "row": 1},
	"towers": {
		"tower": {"type": "sprite", "col": 1, "row": 2},
		"one": {"type": "sprite", "col": 2, "row": 2},
		"two": {"type": "sprite", "col": 3, "row": 2},
		"a_one": {"type": "sprite", "col": 1, "row": 3},
		"a_two": {"type": "sprite", "col": 2, "row": 3},
		"a_three": {"type": "sprite", "col": 3, "row": 3},
		"b_one": {"type": "sprite", "col": 1, "row": 4},
		"b_two": {"type": "sprite", "col": 2, "row": 4},
		"b_three": {"type": "sprite", "col": 3, "row": 4},
		"c_one": {"type": "sprite", "col": 1, "row": 5},
		"c_two": {"type": "sprite", "col": 2, "row": 5},
		"c_three": {"type": "sprite", "col": 3, "row": 5},
	},
	"bullet_one": {"type": "sprite", "col": 2, "row": 1},
}

static var _built := {}

static func sprite(path: String) -> Texture2D:
	return Utils.fetch_sprite(sprites, _built, SHEET, path)

static var towers = Utils.bake_family({
	"insect": INSECT,
	"class": CLASS,
	"sheet": SHEET,
	"sprites": sprites,
	"defaults": {
		"display_name": "Bee",
		"desc": "flies around doing okay damage at long range",
		"targeting": Enums.TargetingType.FIRST,
		"can_see_camo": Enums.CanSeeCamo.CANNOT_SEE_CAMO,
		"max_range": 800,
		"fire_rate": 1,
		"shop_cost": 8,
	},
	"bullet": {
		"speed": 250,
		"guidance": Enums.GuidanceType.SMART,
		"direct_damage": 2,
		"fuse": Enums.Fuse.IMPACT,
	},
	"trunk": [
		{},
		{
			"display_name": "Bigger Stinger",
			"desc": "adds damage to the stinger",
			"shop_cost": 12,
			"bullet": { "direct_damage": 4 },
		},
		{
			"display_name": "Cautionary Colours",
			"desc": "increases flight speed",
			"shop_cost": 16,
			"fire_rate": 1.5,
			"bullet": { "speed": 350 },
		},
	],
	"a": [
		{
			"display_name": "Bumblebee",
			"desc": "heavier hits, slower shots",
			"shop_cost": 20,
			"fire_rate": 1,
			"bullet": { "direct_damage": 8 },
		},
		{
			"display_name": "Glowing Honey",
			"desc": "shots leave a lingering burn",
			"shop_cost": 24,
			"bullet": {
				"status_effect": {
					"status_application": Enums.StatusApplication.DIRECT,
					"status_type": Enums.StatusEffectType.DOT,
					"status_duration": 3,
					"status_strength": 2,
				},
			},
		},
		{
			"display_name": "Nuclear B-actor",
			"desc": "big sting, big burn",
			"shop_cost": 30,
			"bullet": {
				"direct_damage": 12,
				"status_effect": { "status_duration": 5, "status_strength": 4 },
			},
		},
	],
	"b": [
		{
			"display_name": "Hornet",
			"desc": "stings quicker with a sharper stinger",
			"shop_cost": 20,
			"fire_rate": 3,
			"bullet": { "direct_damage": 3, "speed": 400 },
		},
		{
			"display_name": "Rage Bug",
			"desc": "fires faster the longer it is attacking (pending)",
			"shop_cost": 24,
			"fire_rate": 4,
			"special": { "ability": "rage_fire_rate" },
		},
		{
			"display_name": "Vagabond Husk",
			"desc": "now dead, it can go beyond its mortal limits (pending)",
			"shop_cost": 30,
			"fire_rate": 8,
			"bullet": { "direct_damage": 2 },
		},
	],
	"c": [
		{
			"display_name": "Honey Bee",
			"desc": "supports nearby towers (aura pending)",
			"shop_cost": 20,
			"special": { "aura": Enums.AuraType.FIRE_RATE, "aura_strength": 1.5 },
		},
		{
			"display_name": "Sticky Gold",
			"desc": "nearby towers earn extra money on hit (pending)",
			"shop_cost": 24,
			"special": { "aura": Enums.AuraType.MONEY_ON_HIT, "aura_strength": 1.2, "money_on_hit": 1.0 },
		},
		{
			"display_name": "Colony Jewel",
			"desc": "timed boost to nearby towers (pending)",
			"shop_cost": 30,
			"special": { "ability": "colony_boost" },
		},
	],
})
