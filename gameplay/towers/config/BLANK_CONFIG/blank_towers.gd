extends RefCounted
##TEMPLATE ONLY — this file is never registered in tower_registry.gd and never runs.
##To make a new bug family:
## 1. dupe the whole BLANK_CONFIG folder, rename it to the bug name (lowercase, e.g. "scorpion")
## 2. rename blank_towers.gd -> <bug>_towers.gd and blank_sheet.png -> <bug>_sheet.png
## 3. set INSECT below + fix the SHEET preload path. keys + upgrade refs follow
##    automatically (T_*/U_* consts); fill in sprite cells + tower numbers only.
## 4. tune the 12 tower dicts (gameplay numbers per tier, targeting per path)
## 5. add the file to tower_registry.gd (preload + one line each in class_files/towers_config)
##see also: DUPE THE CONTENTS OF THIS TO MAKE A NEW BUG.txt

const Enums = preload("res://main/enums.gd")
const Utils = preload("res://gameplay/towers/config/config_utils.gd")

##1. point at this insect's own sheet (renamed per family, e.g. scorpion_sheet.png)
const SHEET = preload("res://gameplay/towers/config/BLANK_CONFIG/blank_sheet.png")
##2. the one var: class key base. everything below keys off this — change it
##on dupe and all tower keys + upgrade refs follow with zero find-replace.
const INSECT := "blank"

##tower keys: one const per tower. tower = placement, one/two = trunk upgrades,
##then a 3-way branch (a/b/c paths, three tiers each). 1 + 2 + 9 = 12 total.
##typo a key name and you get a parse error (undeclared identifier), not a silent
##wrong string like literal "blank_owo" would give.
const T_TOWER := INSECT + "_tower"
const T_ONE := INSECT + "_one"
const T_TWO := INSECT + "_two"
const T_A_ONE := INSECT + "_a_one"
const T_A_TWO := INSECT + "_a_two"
const T_A_THREE := INSECT + "_a_three"
const T_B_ONE := INSECT + "_b_one"
const T_B_TWO := INSECT + "_b_two"
const T_B_THREE := INSECT + "_b_three"
const T_C_ONE := INSECT + "_c_one"
const T_C_TWO := INSECT + "_c_two"
const T_C_THREE := INSECT + "_c_three"

##upgrade refs: tower -> where it can go. the whole branch tree in one block —
##read trunk, splits, branches, dead ends here instead of across 12 dicts.
##NOTE: const arrays are shared by reference. safe as long as nothing mutates a
##tower's upgrade list at runtime (read-only today: upgrade panel only reads).
##if a mutation is ever needed, .duplicate() at the read site first.
const U_TOWER := [T_ONE]
const U_ONE := [T_TWO]
const U_TWO := [T_A_ONE, T_B_ONE, T_C_ONE]
const U_A_ONE := [T_A_TWO]
const U_A_TWO := [T_A_THREE]
const U_A_THREE := []
const U_B_ONE := [T_B_TWO]
const U_B_TWO := [T_B_THREE]
const U_B_THREE := []
const U_C_ONE := [T_C_TWO]
const U_C_TWO := [T_C_THREE]
const U_C_THREE := []

##MUST match the key this file is registered under in tower_registry.gd,
##and the "class" string inside every tower below
static var class_key := INSECT

##sprite section: THE art authority. one row per tower (row-fixed: same row,
##walk columns). entries are {"type": "sprite", ...} statics or
##{"type": "anim", "from": [c,r], "to": [c,r], "fps": n} ranges; any anim can use
##explicit "cells": [[c,r],...] instead for non-sequential cycles.
##"cell" is the px default; override per entry with "size".
##LAYOUT (1-based col,row — shared by every future spritesheet):
##  (1,1) icon             (2,1) bullet_one   (3,1) spare
##  (1,2) tower   (2,2) one    (3,2) two
##  (1,3) a_one   (2,3) a_two  (3,3) a_three
##  (1,4) b_one   (2,4) b_two  (3,4) b_three
##  (1,5) c_one   (2,5) c_two  (3,5) c_three
##NOTE: 5 rows at 32px 1-based reaches y=192, so the sheet must be >=128x192.
##blank_sheet.png is currently 128x128 — rows 4-5 are placeholders until art lands.
##"towers" sub-dict holds one static {col,row} per tower tier (the single-frame
##tower_texture source); "tower_frames" holds the matching anim ranges.
##NOTE: "tower_frames" still uses the OLD multi-frame scheme (rows 1-12) and has no
##room in the 5-row layout — it needs a taller sheet before anims can be wired up.
##it has zero consumers today (anim() is never called anywhere), so it is left as-is.
##shared visuals live in common/common_assets.gd — reference from tower
##entries as "common/<key>" (resolved by the consumer, not here).
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
	"tower_frames": {
		"tower": {"type": "anim", "from": [2, 1], "to": [5, 1], "fps": 6},
		"one": {"type": "anim", "from": [2, 2], "to": [5, 2], "fps": 6},
		"two": {"type": "anim", "from": [2, 3], "to": [5, 3], "fps": 6},
		# branch rows: uncomment a path's art as it lands. rows 4-12, one per tower.
		# "a_one": {"type": "anim", "from": [2, 4], "to": [5, 4], "fps": 6},
		# "a_two": {"type": "anim", "from": [2, 5], "to": [5, 5], "fps": 6},
		# "a_three": {"type": "anim", "from": [2, 6], "to": [5, 6], "fps": 6},
		# "b_one": {"type": "anim", "from": [2, 7], "to": [5, 7], "fps": 6},
		# "b_two": {"type": "anim", "from": [2, 8], "to": [5, 8], "fps": 6},
		# "b_three": {"type": "anim", "from": [2, 9], "to": [5, 9], "fps": 6},
		# "c_one": {"type": "anim", "from": [2, 10], "to": [5, 10], "fps": 6},
		# "c_two": {"type": "anim", "from": [2, 11], "to": [5, 11], "fps": 6},
		# "c_three": {"type": "anim", "from": [2, 12], "to": [5, 12], "fps": 6},
	},
	"bullet_one": {"type": "sprite", "col": 2, "row": 1},
}

##built cache: key path ("icon", "tower_frames/tower_one", "bullet_one") -> live object.
##passed to Utils.fetch_* (dicts pass by reference), so each family caches its own art.
static var _built := {}

##delegates to the shared machinery in config_utils.gd — data lives here, logic lives there.
static func sprite(path: String) -> Texture2D:
	return Utils.fetch_sprite(sprites, _built, SHEET, path)

##animated accessor: "tower_frames/tower_one" -> SpriteFrames. asserts anim type.
static func anim(path: String) -> SpriteFrames:
	return Utils.fetch_anim(sprites, _built, SHEET, path)

##upgrade chain inside the family namespace: towers[INSECT][T_TOWER] upgrades
##along T_ONE -> T_TWO -> 3-way branch. all keys + refs are T_*/U_* consts above,
##so changing INSECT renames everything. tower dicts carry gameplay numbers + art only —
##every texture coord below is deref'd from `sprites` above, so there is no second copy
##to keep in sync by hand.
##NOTE: two rules keep these lines compiling (both verified in Godot 4.5):
##  * `sprites` MUST stay `const`, not `static var`. const resolves at compile time, so
##    there is no initialization order to get wrong. Reading a sibling *static var* from a
##    static-var initializer is a genuine hazard — it yields <null> at runtime rather than
##    a parse error (godot#104161, godot#110825, both still open as of 4.5).
##  * `towers` MUST stay `static var` — Utils.get_atlas_texture() allocates an AtlasTexture,
##    which no const initializer can do.
##const-dict derefs inside Utils.* calls are fine: tested here, parses clean in 4.5.
static var towers = {
	INSECT: {
	T_TOWER: {
		"icon_texture": Utils.get_atlas_texture(SHEET, sprites["icon"]["col"], sprites["icon"]["row"], sprites["cell"]),
		"tower_texture": Utils.get_atlas_texture(SHEET, sprites["towers"]["tower"]["col"], sprites["towers"]["tower"]["row"], sprites["cell"]),
		"display_name": INSECT.capitalize(),
		"class": INSECT,
		"desc": "template placement — duplicate me",
		"targeting": Enums.TargetingType.FIRST,
		"can_see_camo": Enums.CanSeeCamo.CANNOT_SEE_CAMO,
		"min_range": 0,
		"max_range": 300,
		"fire_rate": 1,
		"shop_cost": 5,
		"bullet_config": {
			"bullet_texture": Utils.get_atlas_texture(SHEET, sprites["bullet_one"]["col"], sprites["bullet_one"]["row"], sprites["cell"]),
			"speed": 300, ##in pixels per second
			"guidance": Enums.GuidanceType.DUMB,
			"direct_damage": 1,
			"fuse": Enums.Fuse.IMPACT,
		},
		"upgrade_options_config_keys": U_TOWER,
	},
	T_ONE: {
		"icon_texture": Utils.get_atlas_texture(SHEET, sprites["icon"]["col"], sprites["icon"]["row"], sprites["cell"]),
		"tower_texture": Utils.get_atlas_texture(SHEET, sprites["towers"]["one"]["col"], sprites["towers"]["one"]["row"], sprites["cell"]),
		"display_name": INSECT.capitalize() + " One",
		"class": INSECT,
		"desc": "template trunk upgrade one",
		"targeting": Enums.TargetingType.FIRST,
		"can_see_camo": Enums.CanSeeCamo.CANNOT_SEE_CAMO,
		"min_range": 0,
		"max_range": 350,
		"fire_rate": 1,
		"shop_cost": 8,
		"bullet_config": {
			"bullet_texture": Utils.get_atlas_texture(SHEET, sprites["bullet_one"]["col"], sprites["bullet_one"]["row"], sprites["cell"]),
			"speed": 325, ##in pixels per second
			"guidance": Enums.GuidanceType.DUMB,
			"direct_damage": 2,
			"fuse": Enums.Fuse.IMPACT,
		},
		"upgrade_options_config_keys": U_ONE,
	},
	T_TWO: {
		"icon_texture": Utils.get_atlas_texture(SHEET, sprites["icon"]["col"], sprites["icon"]["row"], sprites["cell"]),
		"tower_texture": Utils.get_atlas_texture(SHEET, sprites["towers"]["two"]["col"], sprites["towers"]["two"]["row"], sprites["cell"]),
		"display_name": INSECT.capitalize() + " Two",
		"class": INSECT,
		"desc": "template trunk upgrade two — branches three ways",
		"targeting": Enums.TargetingType.FIRST,
		"can_see_camo": Enums.CanSeeCamo.CANNOT_SEE_CAMO,
		"min_range": 0,
		"max_range": 400,
		"fire_rate": 1,
		"shop_cost": 12,
		"bullet_config": {
			"bullet_texture": Utils.get_atlas_texture(SHEET, sprites["bullet_one"]["col"], sprites["bullet_one"]["row"], sprites["cell"]),
			"speed": 350, ##in pixels per second
			"guidance": Enums.GuidanceType.DUMB,
			"direct_damage": 3,
			"fuse": Enums.Fuse.IMPACT,
		},
		"upgrade_options_config_keys": U_TWO,
	},
	# A path tiers live below. B/C paths follow the same pattern.
	T_A_ONE: {
		"icon_texture": Utils.get_atlas_texture(SHEET, sprites["icon"]["col"], sprites["icon"]["row"], sprites["cell"]),
		"tower_texture": Utils.get_atlas_texture(SHEET, sprites["towers"]["a_one"]["col"], sprites["towers"]["a_one"]["row"], sprites["cell"]),
		"display_name": INSECT.capitalize() + " A One",
		"class": INSECT,
		"desc": "template A path tier one",
		"targeting": Enums.TargetingType.FIRST,
		"can_see_camo": Enums.CanSeeCamo.CANNOT_SEE_CAMO,
		"min_range": 0,
		"max_range": 425,
		"fire_rate": 1,
		"shop_cost": 16,
		"bullet_config": {
			"bullet_texture": Utils.get_atlas_texture(SHEET, sprites["bullet_one"]["col"], sprites["bullet_one"]["row"], sprites["cell"]),
			"speed": 375, ##in pixels per second
			"guidance": Enums.GuidanceType.DUMB,
			"direct_damage": 4,
			"fuse": Enums.Fuse.IMPACT,
		},
		"upgrade_options_config_keys": U_A_ONE,
	},
	T_A_TWO: {
		"icon_texture": Utils.get_atlas_texture(SHEET, sprites["icon"]["col"], sprites["icon"]["row"], sprites["cell"]),
		"tower_texture": Utils.get_atlas_texture(SHEET, sprites["towers"]["a_two"]["col"], sprites["towers"]["a_two"]["row"], sprites["cell"]),
		"display_name": INSECT.capitalize() + " A Two",
		"class": INSECT,
		"desc": "template A path tier two",
		"targeting": Enums.TargetingType.FIRST,
		"can_see_camo": Enums.CanSeeCamo.CANNOT_SEE_CAMO,
		"min_range": 0,
		"max_range": 450,
		"fire_rate": 1,
		"shop_cost": 20,
		"bullet_config": {
			"bullet_texture": Utils.get_atlas_texture(SHEET, sprites["bullet_one"]["col"], sprites["bullet_one"]["row"], sprites["cell"]),
			"speed": 400, ##in pixels per second
			"guidance": Enums.GuidanceType.DUMB,
			"direct_damage": 5,
			"fuse": Enums.Fuse.IMPACT,
		},
		"upgrade_options_config_keys": U_A_TWO,
	},
	T_A_THREE: {
		"icon_texture": Utils.get_atlas_texture(SHEET, sprites["icon"]["col"], sprites["icon"]["row"], sprites["cell"]),
		"tower_texture": Utils.get_atlas_texture(SHEET, sprites["towers"]["a_three"]["col"], sprites["towers"]["a_three"]["row"], sprites["cell"]),
		"display_name": INSECT.capitalize() + " A Three",
		"class": INSECT,
		"desc": "template A path final tier",
		"targeting": Enums.TargetingType.FIRST,
		"can_see_camo": Enums.CanSeeCamo.CAN_SEE_CAMO,
		"min_range": 0,
		"max_range": 475,
		"fire_rate": 1,
		"shop_cost": 25,
		"bullet_config": {
			"bullet_texture": Utils.get_atlas_texture(SHEET, sprites["bullet_one"]["col"], sprites["bullet_one"]["row"], sprites["cell"]),
			"speed": 425, ##in pixels per second
			"guidance": Enums.GuidanceType.DUMB,
			"direct_damage": 6,
			"fuse": Enums.Fuse.IMPACT,
		},
		"upgrade_options_config_keys": U_A_THREE,
	},
	# B path: same pattern, art rows 7-9, CLOSEST targeting.
	T_B_ONE: {
		"icon_texture": Utils.get_atlas_texture(SHEET, sprites["icon"]["col"], sprites["icon"]["row"], sprites["cell"]),
		"tower_texture": Utils.get_atlas_texture(SHEET, sprites["towers"]["b_one"]["col"], sprites["towers"]["b_one"]["row"], sprites["cell"]),
		"display_name": INSECT.capitalize() + " B One",
		"class": INSECT,
		"desc": "template B path tier one",
		"targeting": Enums.TargetingType.CLOSEST,
		"can_see_camo": Enums.CanSeeCamo.CANNOT_SEE_CAMO,
		"min_range": 0,
		"max_range": 425,
		"fire_rate": 1,
		"shop_cost": 16,
		"bullet_config": {
			"bullet_texture": Utils.get_atlas_texture(SHEET, sprites["bullet_one"]["col"], sprites["bullet_one"]["row"], sprites["cell"]),
			"speed": 375, ##in pixels per second
			"guidance": Enums.GuidanceType.DUMB,
			"direct_damage": 4,
			"fuse": Enums.Fuse.IMPACT,
		},
		"upgrade_options_config_keys": U_B_ONE,
	},
	T_B_TWO: {
		"icon_texture": Utils.get_atlas_texture(SHEET, sprites["icon"]["col"], sprites["icon"]["row"], sprites["cell"]),
		"tower_texture": Utils.get_atlas_texture(SHEET, sprites["towers"]["b_two"]["col"], sprites["towers"]["b_two"]["row"], sprites["cell"]),
		"display_name": INSECT.capitalize() + " B Two",
		"class": INSECT,
		"desc": "template B path tier two",
		"targeting": Enums.TargetingType.CLOSEST,
		"can_see_camo": Enums.CanSeeCamo.CANNOT_SEE_CAMO,
		"min_range": 0,
		"max_range": 450,
		"fire_rate": 1,
		"shop_cost": 20,
		"bullet_config": {
			"bullet_texture": Utils.get_atlas_texture(SHEET, sprites["bullet_one"]["col"], sprites["bullet_one"]["row"], sprites["cell"]),
			"speed": 400, ##in pixels per second
			"guidance": Enums.GuidanceType.DUMB,
			"direct_damage": 5,
			"fuse": Enums.Fuse.IMPACT,
		},
		"upgrade_options_config_keys": U_B_TWO,
	},
	T_B_THREE: {
		"icon_texture": Utils.get_atlas_texture(SHEET, sprites["icon"]["col"], sprites["icon"]["row"], sprites["cell"]),
		"tower_texture": Utils.get_atlas_texture(SHEET, sprites["towers"]["b_three"]["col"], sprites["towers"]["b_three"]["row"], sprites["cell"]),
		"display_name": INSECT.capitalize() + " B Three",
		"class": INSECT,
		"desc": "template B path final tier",
		"targeting": Enums.TargetingType.CLOSEST,
		"can_see_camo": Enums.CanSeeCamo.CAN_SEE_CAMO,
		"min_range": 0,
		"max_range": 475,
		"fire_rate": 1,
		"shop_cost": 25,
		"bullet_config": {
			"bullet_texture": Utils.get_atlas_texture(SHEET, sprites["bullet_one"]["col"], sprites["bullet_one"]["row"], sprites["cell"]),
			"speed": 425, ##in pixels per second
			"guidance": Enums.GuidanceType.DUMB,
			"direct_damage": 6,
			"fuse": Enums.Fuse.IMPACT,
		},
		"upgrade_options_config_keys": U_B_THREE,
	},
	# C path: same pattern, art rows 10-12, STRONGEST targeting.
	T_C_ONE: {
		"icon_texture": Utils.get_atlas_texture(SHEET, sprites["icon"]["col"], sprites["icon"]["row"], sprites["cell"]),
		"tower_texture": Utils.get_atlas_texture(SHEET, sprites["towers"]["c_one"]["col"], sprites["towers"]["c_one"]["row"], sprites["cell"]),
		"display_name": INSECT.capitalize() + " C One",
		"class": INSECT,
		"desc": "template C path tier one",
		"targeting": Enums.TargetingType.STRONGEST,
		"can_see_camo": Enums.CanSeeCamo.CANNOT_SEE_CAMO,
		"min_range": 0,
		"max_range": 425,
		"fire_rate": 1,
		"shop_cost": 16,
		"bullet_config": {
			"bullet_texture": Utils.get_atlas_texture(SHEET, sprites["bullet_one"]["col"], sprites["bullet_one"]["row"], sprites["cell"]),
			"speed": 375, ##in pixels per second
			"guidance": Enums.GuidanceType.DUMB,
			"direct_damage": 4,
			"fuse": Enums.Fuse.IMPACT,
		},
		"upgrade_options_config_keys": U_C_ONE,
	},
	T_C_TWO: {
		"icon_texture": Utils.get_atlas_texture(SHEET, sprites["icon"]["col"], sprites["icon"]["row"], sprites["cell"]),
		"tower_texture": Utils.get_atlas_texture(SHEET, sprites["towers"]["c_two"]["col"], sprites["towers"]["c_two"]["row"], sprites["cell"]),
		"display_name": INSECT.capitalize() + " C Two",
		"class": INSECT,
		"desc": "template C path tier two",
		"targeting": Enums.TargetingType.STRONGEST,
		"can_see_camo": Enums.CanSeeCamo.CANNOT_SEE_CAMO,
		"min_range": 0,
		"max_range": 450,
		"fire_rate": 1,
		"shop_cost": 20,
		"bullet_config": {
			"bullet_texture": Utils.get_atlas_texture(SHEET, sprites["bullet_one"]["col"], sprites["bullet_one"]["row"], sprites["cell"]),
			"speed": 400, ##in pixels per second
			"guidance": Enums.GuidanceType.DUMB,
			"direct_damage": 5,
			"fuse": Enums.Fuse.IMPACT,
		},
		"upgrade_options_config_keys": U_C_TWO,
	},
	T_C_THREE: {
		"icon_texture": Utils.get_atlas_texture(SHEET, sprites["icon"]["col"], sprites["icon"]["row"], sprites["cell"]),
		"tower_texture": Utils.get_atlas_texture(SHEET, sprites["towers"]["c_three"]["col"], sprites["towers"]["c_three"]["row"], sprites["cell"]),
		"display_name": INSECT.capitalize() + " C Three",
		"class": INSECT,
		"desc": "template C path final tier",
		"targeting": Enums.TargetingType.STRONGEST,
		"can_see_camo": Enums.CanSeeCamo.CAN_SEE_CAMO,
		"min_range": 0,
		"max_range": 475,
		"fire_rate": 1,
		"shop_cost": 25,
		"bullet_config": {
			"bullet_texture": Utils.get_atlas_texture(SHEET, sprites["bullet_one"]["col"], sprites["bullet_one"]["row"], sprites["cell"]),
			"speed": 425, ##in pixels per second
			"guidance": Enums.GuidanceType.DUMB,
			"direct_damage": 6,
			"fuse": Enums.Fuse.IMPACT,
		},
		"upgrade_options_config_keys": U_C_THREE,
	},
	},
}
