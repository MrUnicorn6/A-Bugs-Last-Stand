extends RefCounted
##beetle family: same 12-slot delta tree as ant / BLANK.
##old keys (beetle, scarab_one, ...) are now beetle_tower / beetle_a_one / ...
##Loader.towers_config["beetles"]["beetle_tower"]

const Enums = preload("res://main/enums.gd")
const Utils = preload("res://gameplay/towers/config/config_utils.gd")

const SHEET = preload("res://gameplay/towers/config/beetle/beetle_art.png")
const INSECT := "beetle"
const CLASS := "beetles"

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

##fire_rate is shots per second. Doc-described special effects that the combat
##runtime does not support are marked pending in their upgrade descriptions.
static var towers = Utils.bake_family({
	"insect": INSECT,
	"class": CLASS,
	"sheet": SHEET,
	"sprites": sprites,
	"defaults": {
		"display_name": "Beetle",
		"desc": "close-range ball attacker; pierce effect pending",
		"targeting": Enums.TargetingType.FIRST,
		"can_see_camo": Enums.CanSeeCamo.CANNOT_SEE_CAMO,
		"max_range": 200,
		"fire_rate": 0.25,
		"shop_cost": 10,
	},
	"bullet": {
		"speed": 150,
		"guidance": Enums.GuidanceType.BALL,
		"fuse": Enums.Fuse.TIMER,
		"fuse_value": 2,
		"direct_damage": 5,
		"aoe_radius": 60,
		"lifetime": 5.0,
	},
	"special": { "weapon": Enums.WeaponType.BALL, "pierce": 1 },
	"trunk": [
		{},
		{
			"display_name": "Bigger Ball",
			"desc": "extra damage and configured pierce (pierce effect pending)",
			"targeting": Enums.TargetingType.CLOSEST,
			"max_range": 300,
			"bullet": { "speed": 175, "direct_damage": 8 },
			"special": { "pierce": 2 },
		},
		{
			"display_name": "Stronger Neck",
			"desc": "increase in firing speed",
			"shop_cost": 20,
			"fire_rate": 0.4,
			"bullet": { "speed": 200, "fuse_value": 3, "direct_damage": 10 },
		},
	],
	"a": [
		{
			"display_name": "Scarab",
			"desc": "ball detonates into a flash that stuns nearby droids",
			"shop_cost": 20,
			"bullet": {
				"fuse": Enums.Fuse.TIMER_EXPLOSIVE,
				"status_effects": [{
					"status_application": Enums.StatusApplication.AOE,
					"status_type": Enums.StatusEffectType.STUN,
					"status_duration": 1.5,
					"status_strength": 1.0,
				}],
			},
		},
		{
			"display_name": "Auric Gleam",
			"desc": "increases stun range and duration",
			"max_range": 350,
			"shop_cost": 24,
			"bullet": {
				"aoe_radius": 80,
				"status_effects": [{
					"status_application": Enums.StatusApplication.AOE,
					"status_type": Enums.StatusEffectType.STUN,
					"status_duration": 2.5,
					"status_strength": 1.0,
				}],
			},
		},
		{
			"display_name": "Iridescent Napalm",
			"desc": "adds burn to ball hits and flash, with increased damage",
			"shop_cost": 28,
			"bullet": {
				"direct_damage": 14,
				"status_effects": [
					{
						"status_application": Enums.StatusApplication.AOE,
						"status_type": Enums.StatusEffectType.STUN,
						"status_duration": 2.5,
						"status_strength": 1.0,
					},
					{
						"status_application": Enums.StatusApplication.AOE,
						"status_type": Enums.StatusEffectType.DOT,
						"status_duration": 4,
						"status_strength": 3,
					},
					{
						"status_application": Enums.StatusApplication.DIRECT,
						"status_type": Enums.StatusEffectType.DOT,
						"status_duration": 4,
						"status_strength": 3,
					},
				],
			},
		},
	],
	"b": [
		{
			"display_name": "Dung Beetle",
			"desc": "rolls boulders that slow droids on impact (pushback pending)",
			"shop_cost": 20,
			"bullet": {
				"direct_damage": 7,
				"status_effect": {
					"status_application": Enums.StatusApplication.DIRECT,
					"status_type": Enums.StatusEffectType.SLOW,
					"status_duration": 4,
					"status_strength": 2,
				},
			},
		},
		{
			"display_name": "Inferno Ball",
			"desc": "increase in speed and duration of ball",
			"shop_cost": 24,
			"bullet": { "speed": 250, "fuse_value": 4 },
		},
		{
			"display_name": "Igneous Orb",
			"desc": "lights the path behind it and explodes on death (effects pending)",
			"shop_cost": 28,
			"bullet": { "direct_damage": 12, "aoe_radius": 80 },
		},
	],
	"c": [
		{
			"display_name": "Atlas",
			"desc": "pinch attack that grabs smaller droids and kills them over time (pending)",
			"shop_cost": 20,
			"special": { "weapon": Enums.WeaponType.GRAB },
		},
		{
			"display_name": "Prince of Stags",
			"desc": "faster destruction time",
			"shop_cost": 24,
			"fire_rate": 0.4,
		},
		{
			"display_name": "King of Beetles",
			"desc": "can grab smaller elites with a quicker cooldown on smaller enemies (pending)",
			"shop_cost": 28,
			"fire_rate": 0.5,
		},
	],
})
