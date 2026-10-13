extends RefCounted
##TEMPLATE ONLY — never registered in tower_registry.gd.
##To make a new bug family:
## 1. dupe this folder, rename it (lowercase, e.g. "scorpion")
## 2. rename blank_towers.gd -> <bug>_towers.gd and blank_sheet.png -> <bug>_sheet.png
## 3. set INSECT + CLASS + SHEET. bake_family() builds keys (scorpion_tower, ...)
## 4. fill defaults, then only the *changes* on each of the 12 slots
## 5. register the file in tower_registry.gd

const Enums = preload("res://main/enums.gd")
const Utils = preload("res://gameplay/towers/config/config_utils.gd")

const SHEET = preload("res://gameplay/towers/config/BLANK_CONFIG/blank_sheet.png")
const INSECT := "blank"
##registry key. ant uses plural "ants"; keep this equal to INSECT until you register.
const CLASS := INSECT

static var class_key := CLASS

##LAYOUT (1-based col,row — shared by every family sheet):
##  (1,1) icon             (2,1) bullet_one   (3,1) spare
##  (1,2) tower   (2,2) one    (3,2) two
##  (1,3) a_one   (2,3) a_two  (3,3) a_three
##  (1,4) b_one   (2,4) b_two  (3,4) b_three
##  (1,5) c_one   (2,5) c_two  (3,5) c_three
##blank_sheet.png is 128x128 — rows 4-5 are off-sheet placeholders until art lands.
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
		"display_name": INSECT.capitalize(),
		"desc": "template placement — duplicate me",
		"targeting": Enums.TargetingType.FIRST,
		"can_see_camo": Enums.CanSeeCamo.CANNOT_SEE_CAMO,
		"max_range": 300,
		"fire_rate": 1,
		"shop_cost": 5,
	},
	"bullet": {
		"speed": 300,
		"guidance": Enums.GuidanceType.DUMB,
		"direct_damage": 1,
		"fuse": Enums.Fuse.IMPACT,
	},
	"trunk": [
		{},
		{
			"display_name": INSECT.capitalize() + " One",
			"desc": "template trunk upgrade one",
			"max_range": 350,
			"shop_cost": 8,
			"bullet": { "speed": 325, "direct_damage": 2 },
		},
		{
			"display_name": INSECT.capitalize() + " Two",
			"desc": "template trunk upgrade two — branches three ways",
			"max_range": 400,
			"shop_cost": 12,
			"bullet": { "speed": 350, "direct_damage": 3 },
		},
	],
	"a": [
		{
			"display_name": INSECT.capitalize() + " A One",
			"desc": "template A path tier one",
			"max_range": 425,
			"shop_cost": 16,
			"bullet": { "speed": 375, "direct_damage": 4 },
		},
		{
			"display_name": INSECT.capitalize() + " A Two",
			"desc": "template A path tier two",
			"max_range": 450,
			"shop_cost": 20,
			"bullet": { "speed": 400, "direct_damage": 5 },
		},
		{
			"display_name": INSECT.capitalize() + " A Three",
			"desc": "template A path final tier",
			"can_see_camo": Enums.CanSeeCamo.CAN_SEE_CAMO,
			"max_range": 475,
			"shop_cost": 25,
			"bullet": { "speed": 425, "direct_damage": 6 },
		},
	],
	"b": [
		{
			"display_name": INSECT.capitalize() + " B One",
			"desc": "template B path tier one",
			"targeting": Enums.TargetingType.CLOSEST,
			"max_range": 425,
			"shop_cost": 16,
			"bullet": { "speed": 375, "direct_damage": 4 },
		},
		{
			"display_name": INSECT.capitalize() + " B Two",
			"desc": "template B path tier two",
			"max_range": 450,
			"shop_cost": 20,
			"bullet": { "speed": 400, "direct_damage": 5 },
		},
		{
			"display_name": INSECT.capitalize() + " B Three",
			"desc": "template B path final tier",
			"can_see_camo": Enums.CanSeeCamo.CAN_SEE_CAMO,
			"max_range": 475,
			"shop_cost": 25,
			"bullet": { "speed": 425, "direct_damage": 6 },
		},
	],
	"c": [
		{
			"display_name": INSECT.capitalize() + " C One",
			"desc": "template C path tier one",
			"targeting": Enums.TargetingType.STRONGEST,
			"max_range": 425,
			"shop_cost": 16,
			"bullet": { "speed": 375, "direct_damage": 4 },
		},
		{
			"display_name": INSECT.capitalize() + " C Two",
			"desc": "template C path tier two",
			"max_range": 450,
			"shop_cost": 20,
			"bullet": { "speed": 400, "direct_damage": 5 },
		},
		{
			"display_name": INSECT.capitalize() + " C Three",
			"desc": "template C path final tier",
			"can_see_camo": Enums.CanSeeCamo.CAN_SEE_CAMO,
			"max_range": 475,
			"shop_cost": 25,
			"bullet": { "speed": 425, "direct_damage": 6 },
		},
	],
})
