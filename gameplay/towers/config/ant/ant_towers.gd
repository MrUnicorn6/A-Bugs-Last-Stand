extends RefCounted
##ant family: 12-slot tree of *deltas*. Utils.bake_family() fills textures,
##upgrade keys, class, and special. Loader.towers_config["ants"]["ant_tower"].
##
##to make a new bug: dupe BLANK_CONFIG, set INSECT + CLASS + SHEET, fill diffs.

const Enums = preload("res://main/enums.gd")
const Utils = preload("res://gameplay/towers/config/config_utils.gd")

const SHEET = preload("res://gameplay/towers/config/ant/ant_art.png")
const VFX_ART = preload("res://gameplay/towers/config/common/vfx_art.png")

const INSECT := "ant"
const CLASS := "ants"

static var class_key := CLASS

##LAYOUT (raw col/row into a 32px grid). ant puts "two" at (2,3) and a_three
##at (3,2) instead of BLANK's (3,2)/(3,3).
const sprites := {
	"cell": 32,
	"icon": {"type": "sprite", "col": 1, "row": 1},
	"towers": {
		"tower": {"type": "sprite", "col": 1, "row": 2},
		"one": {"type": "sprite", "col": 2, "row": 2},
		"two": {"type": "sprite", "col": 2, "row": 3},
		"a_one": {"type": "sprite", "col": 1, "row": 3},
		"a_two": {"type": "sprite", "col": 3, "row": 3},
		"a_three": {"type": "sprite", "col": 3, "row": 2},
		"b_one": {"type": "sprite", "col": 1, "row": 4},
		"b_two": {"type": "sprite", "col": 2, "row": 4},
		"b_three": {"type": "sprite", "col": 3, "row": 4},
		"c_one": {"type": "sprite", "col": 1, "row": 5},
		"c_two": {"type": "sprite", "col": 2, "row": 5},
		"c_three": {"type": "sprite", "col": 3, "row": 5},
	},
}

static var _built := {}

static func sprite(path: String) -> Texture2D:
	return Utils.fetch_sprite(sprites, _built, SHEET, path)

##fire_rate is shots per second (base_tower cooldown = 1.0 / fire_rate).
static var towers = Utils.bake_family({
	"insect": INSECT,
	"class": CLASS,
	"sheet": SHEET,
	"sprites": sprites,
	"defaults": {
		"display_name": "ant",
		"desc": "decent damage at medium range",
		"targeting": Enums.TargetingType.FIRST,
		"can_see_camo": Enums.CanSeeCamo.CANNOT_SEE_CAMO,
		"max_range": 300,
		"fire_rate": 2,
		"shop_cost": 5,
	},
	"bullet": {
		"bullet_texture": Utils.get_atlas_texture(VFX_ART, 1, 2, 32),
		"speed": 200,
		"guidance": Enums.GuidanceType.LEAD,
		"direct_damage": 1,
		"fuse": Enums.Fuse.IMPACT,
	},
	"trunk": [
		{},
		{
			"display_name": "Strong Jaw",
			"desc": "increase in damage and range",
			"max_range": 400,
			"shop_cost": 8,
			"bullet": {
				"speed": 350,
				"guidance": Enums.GuidanceType.SMART,
				"direct_damage": 7,
			},
		},
		{
			"display_name": "Better Carapace",
			"desc": "improves the body: buffs fire rate and gains cloak detection",
			"can_see_camo": Enums.CanSeeCamo.CAN_SEE_CAMO,
			"fire_rate": 3,
			"shop_cost": 12,
			"bullet": { "direct_damage": 10 },
		},
	],
	"a": [
		{
			"display_name": "Fire Ant",
			"desc": "adds fire damage: burns its target over time",
			"targeting": Enums.TargetingType.CLOSEST,
			"fire_rate": 2,
			"shop_cost": 16,
			"bullet": {
				"speed": 300,
				"guidance": Enums.GuidanceType.SMART,
				"direct_damage": 5,
				"status_effect": {
					"status_application": Enums.StatusApplication.DIRECT,
					"status_type": Enums.StatusEffectType.DOT,
					"status_duration": 4,
					"status_strength": 4,
				},
			},
		},
		{
			"display_name": "Burning Core",
			"desc": "longer, stronger burn",
			"shop_cost": 20,
			"bullet": {
				"direct_damage": 7,
				"status_effect": { "status_duration": 7, "status_strength": 7 },
			},
		},
		{
			"display_name": "Living Furnace",
			"desc": "turns its shots into a stream of fire that burns everything in its sights",
			"max_range": 450,
			"fire_rate": 12, ##beam not wired; high rate + DOT stands in
			"shop_cost": 25,
			"bullet": {
				"speed": 400,
				"direct_damage": 2,
				"status_effect": { "status_duration": 4, "status_strength": 3 },
			},
			"special": { "weapon": Enums.WeaponType.BEAM },
		},
	],
	"b": [
		{
			"display_name": "Bullet Ant",
			"desc": "major buff to fire rate",
			"fire_rate": 8,
			"shop_cost": 16,
			"bullet": {
				"speed": 400,
				"guidance": Enums.GuidanceType.LEAD,
				"direct_damage": 2,
			},
		},
		{
			"display_name": "Termantator",
			"desc": "more pierce, target locking, and Last targeting",
			"max_range": 425,
			"fire_rate": 10,
			"shop_cost": 20,
			"targeting_options": [
				Enums.TargetingType.FIRST,
				Enums.TargetingType.STRONGEST,
				Enums.TargetingType.LAST,
			],
			"bullet": { "speed": 450, "direct_damage": 3 },
			"special": { "pierce": 1, "select_target": true },
		},
		{
			"display_name": "Ant-I Machine-Mortar",
			"desc": "slow-firing missile that blasts everything in its radius",
			"max_range": 450,
			"fire_rate": 0.5,
			"shop_cost": 25,
			"bullet": {
				"speed": 150,
				"guidance": Enums.GuidanceType.DUMB,
				"direct_damage": 5,
				"fuse": Enums.Fuse.POINT,
				"aoe_radius": 80,
				"aoe_damage": 30,
			},
			"special": { "pierce": 0, "select_target": false },
		},
	],
	"c": [
		{
			"display_name": "Honeypot Ant",
			"desc": "boosts the fire rate of nearby towers (aura pending)",
			"fire_rate": 3,
			"shop_cost": 16,
			"bullet": {
				"speed": 300,
				"guidance": Enums.GuidanceType.LEAD,
				"direct_damage": 4,
			},
			"special": { "aura": Enums.AuraType.FIRE_RATE, "aura_strength": 1.5 },
		},
		{
			"display_name": "Gracious Leader",
			"desc": "nearby towers earn extra money on hit; more range (money aura pending)",
			"max_range": 450,
			"fire_rate": 4,
			"shop_cost": 20,
			"bullet": { "direct_damage": 5 },
			"special": { "aura": Enums.AuraType.MONEY_ON_HIT, "aura_strength": 1.2, "money_on_hit": 1.0 },
		},
		{
			"display_name": "Royal Cauldron",
			"desc": "ability: doubles fire rate of nearby towers (ability pending)",
			"fire_rate": 5,
			"shop_cost": 25,
			"bullet": { "direct_damage": 6 },
			"special": { "ability": Enums.AbilityType.DOUBLE_NEARBY_FIRE_RATE },
		},
	],
})
