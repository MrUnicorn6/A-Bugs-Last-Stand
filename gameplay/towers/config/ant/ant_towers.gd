extends RefCounted
##every ant tower config, in one place.
##wired into Loader.towers_config["ants"] by res://gameplay/towers/config/tower_registry.gd
##to look one up: Loader.get_tower("ant_one")  (same as towers_config["ants"]["ant_one"])
##
##BLANK_CONFIG template applied to ant. what changed vs the old file:
##  * icon + tower textures now deref "sprites" below instead of literal coords
##  * T_*/U_* consts replace bare string keys, so a typo is a parse error
##  * tower KEYS follow BLANK naming (old -> new):
##      ant_two->ant_one, ant_three->ant_two, ant_gunner->ant_a_one, fire_ant->ant_a_two
##    display_name strings now follow the design doc instead of the old words,
##    so the shop / upgrade panel show the design names (Strong Jaw, Fire Ant, ...).
##  * full BLANK upgrade tree filled in: trunk then a 3-way branch, 12 towers:
##      ant -> ant_one (Strong Jaw) -> ant_two (Better Carapace)
##        a: ant_a_one (Fire Ant) -> ant_a_two (Burning Core) -> ant_a_three (Living Furnace)
##        b: ant_b_one (Bullet Ant) -> ant_b_two (Termantator) -> ant_b_three (Ant-I Machine-Mortar)
##        c: ant_c_one (Honeypot Ant) -> ant_c_two (Gracious Leader) -> ant_c_three (Royal Cauldron)
##  * two class consts instead of BLANK one (see INSECT / CLASS below)
##
##DESIGN FEATURES NOT POSSIBLE YET (kept in "desc" only, nothing wired for them):
##  * pierce (Termantator): base_bullet frees itself on the first enemy it hits
##  * manual target select (Termantator): there is no UI to pick a target yet
##  * fire stream / beam (Living Furnace): approximated with extreme fire rate + burn DOT
##  * aura buffs (Honeypot Ant, Gracious Leader) and timed abilities (Royal Cauldron):
##    no tower-to-tower buff or ability system yet, so the c path towers are
##    stat-only placeholders for now
##  * money on hit (Gracious Leader): bullets have no economy hooks
##
##NOTE: "towers" here is FLAT ({tower_key: config}) while BLANK_CONFIG nests it
##({INSECT: {tower_key: config}}). flat is REQUIRED: tower_registry.gd assigns
##towers_config["ants"] = AntTowers.towers and main.gd indexes
##all_towers_dict["ants"]["ant_tower"], so a nested dict would break the shop AND
##Loader.get_tower(), which only walks one level deep.

const Enums = preload("res://main/enums.gd")
const Utils = preload("res://gameplay/towers/config/config_utils.gd")

##the family art sheet: icon + every tower texture. bullets do NOT use this.
##ant_art.png is 640x640 (32px cells = a 20x20 grid). rows 4 and 5 already hold
##drawn ant sprites for the b and c paths (an old comment here wrongly said 128x128).
const SHEET = preload("res://gameplay/towers/config/ant/ant_art.png")
##bullet atlases, read by the bullet_config entries below:
##  TESTING_ATLAS -> ant, ant_one, ant_two only (carried over from the old file)
##    KNOWN ISSUE (pre-existing, untouched here): tower_defense_tilesheet.png is 192x64
##    but those lines ask for cell (22,10) at 64px = origin (1408,640), far outside
##    the image - so those three bullets currently render blank.
##  VFX_ATLAS cell (0,1) = small orange dot -> every a/b/c path tower
const TESTING_ATLAS = preload("res://assets/tower_defense_tilesheet.png")
const VFX_ATLAS = preload("res://assets/vfx_atlas.png")

##class key base - drives the T_* tower keys below. NOT the registry key.
const INSECT := "ant"
##registry key: must match tower_registry.gd AND the "class" field on every tower.
##ant is registered as "ants" (plural) so it cannot be derived from INSECT.
const CLASS := "ants"

##tower keys: one const per tower, BLANK naming scheme (INSECT + "_<slot>").
##all 12 slots are used now: placement + 2 trunk upgrades + 3 branches x 3 tiers.
##  tower = placement, one/two = trunk upgrades, a/b/c = the three branch paths.
##NOTE: T_TOWER is INSECT + "_tower" = "ant_tower" - that exact string is what
##main.gd:29 indexes (all_towers_dict["ants"]["ant_tower"]), so do not rename it.
##what each slot was called before the rename:
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

##upgrade refs: tower -> where it can go. full BLANK tree in one block:
##  ant (placement) -> ant_one (Strong Jaw) -> ant_two (Better Carapace)
##  -> fork into the a/b/c paths, each runs one -> two -> three and stops.
##NOTE: the old file branched instead (ant -> [ant_two, ant_gunner],
##ant_two -> [ant_three, fire_ant]) and ant_three upgraded to itself. both were
##straightened out to match the a_one/a_two naming - this was a gameplay change.
##NOTE: const arrays are shared by reference. safe as long as nothing mutates a
##tower upgrade list at runtime (read-only today: upgrade panel only reads).
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
static var class_key := CLASS

##sprite section: THE art authority for icon + tower textures.
##LAYOUT (numbers below are raw col/row into a 32px grid, same convention as
##BLANK_CONFIG, so prose like "(1,1)" maps straight onto these values):
##  (1,1) icon
##  (1,2) tower   (2,2) one      <- trunk. ant places its "two" at (2,3): see below
##  (1,3) a_one   (2,3) two      (3,3) a_two
##  (3,2) a_three <- only cell left in the trunk block (BLANK would have put
##                   "two" at (3,2) and a_three at (3,3); ant deviates from that)
##  (1,4) b_one   (2,4) b_two    (3,4) b_three  <- already drawn in the sheet
##  (1,5) c_one   (2,5) c_two    (3,5) c_three  <- already drawn in the sheet
##all cells above carry real art: rows 4-5 were drawn but unreferenced until now.
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

##built cache: key path -> live object, passed to Utils.fetch_sprite so the family
##caches its own art instead of rebuilding it on every read.
static var _built := {}

##delegates to the shared machinery in config_utils.gd - data lives here, logic lives there.
static func sprite(path: String) -> Texture2D:
	return Utils.fetch_sprite(sprites, _built, SHEET, path)

##NOTE: no anim() and no "tower_frames" here - ant layout is one static cell per
##tower with no room for frame ranges, and nothing in the game calls anim() anyway.

##static and hopefully constant/unchanging dict of all ant towers and their configs
##NOTE: three rules keep the texture lines below compiling (all verified in Godot 4.5):
##  * "sprites" MUST stay "const" - const resolves at compile time, so there is no
##    initialization order to get wrong. Reading a sibling *static var* from a
##    static-var initializer yields <null> at runtime, not a parse error
##    (godot#104161, godot#110825, both open as of 4.5).
##  * "towers" MUST stay "static var" - Utils.get_atlas_texture() allocates an
##    AtlasTexture, which no const initializer can do.
##  * "fire_rate" is SHOTS PER SECOND: base_tower.gd sets cooldown = 1.0 / fire_rate,
##    so bigger = faster. the old "expressed in delay between shots in seconds" comments
##    in this file (and beetle) were backwards.
static var towers = {
	T_TOWER: {
		"icon_texture": Utils.get_atlas_texture(SHEET, sprites["icon"]["col"], sprites["icon"]["row"], sprites["cell"]),
		"tower_texture": Utils.get_atlas_texture(SHEET, sprites["towers"]["tower"]["col"], sprites["towers"]["tower"]["row"], sprites["cell"]),
		"display_name": "ant",
		"class": CLASS, #MUST MATCH ABOVE CLASS NAME( like ants, beeltes, bees ect), used to find other upgraded ants ect..
		"desc": "decent damage at medium range",
		"targeting": Enums.TargetingType.FIRST,
		"can_see_camo": Enums.CanSeeCamo.CANNOT_SEE_CAMO,
		"min_range": 0,
		"max_range": 300,
		"fire_rate": 2,
		"shop_cost": 5,
		"bullet_config": {
			"bullet_texture": Utils.get_atlas_texture(TESTING_ATLAS,22,10,64),
			"speed": 200,##in pixles per second
			"guidance": Enums.GuidanceType.LEAD,
			"direct_damage": 1,#to whatever it hits, usually its intended target
			"fuse": Enums.Fuse.IMPACT,
		},
		"upgrade_options_config_keys": U_TOWER,
	},
	T_ONE: {
		"icon_texture": Utils.get_atlas_texture(SHEET, sprites["icon"]["col"], sprites["icon"]["row"], sprites["cell"]),
		"tower_texture": Utils.get_atlas_texture(SHEET, sprites["towers"]["one"]["col"], sprites["towers"]["one"]["row"], sprites["cell"]),
		"display_name": "Strong Jaw",
		"class": CLASS,
		"desc": "increase in damage and range",
		"targeting": Enums.TargetingType.FIRST,
		"can_see_camo": Enums.CanSeeCamo.CANNOT_SEE_CAMO,
		"min_range": 0,
		"max_range": 400,
		"fire_rate": 2,##same as base ant: Strong Jaw only sells damage + range
		"shop_cost": 8,
		"bullet_config": {
			"bullet_texture": Utils.get_atlas_texture(TESTING_ATLAS,22,10,64),
			"speed": 350,##in pixles per second
			"guidance": Enums.GuidanceType.SMART,
			"direct_damage": 7,#to whatever it hits, usually its intended target
			"fuse": Enums.Fuse.IMPACT,
		},
		"upgrade_options_config_keys": U_ONE,
	},
	T_TWO: {
		"icon_texture": Utils.get_atlas_texture(SHEET, sprites["icon"]["col"], sprites["icon"]["row"], sprites["cell"]),
		"tower_texture": Utils.get_atlas_texture(SHEET, sprites["towers"]["two"]["col"], sprites["towers"]["two"]["row"], sprites["cell"]),
		"display_name": "Better Carapace",
		"class": CLASS,
		"desc": "improves the body: buffs fire rate and gains cloak detection",
		"targeting": Enums.TargetingType.FIRST,
		"can_see_camo": Enums.CanSeeCamo.CAN_SEE_CAMO,
		"min_range": 0,
		"max_range": 400,
		"fire_rate": 3,##was 0.75 which was slower than base (fire_rate is per second)
		"shop_cost": 12,
		"bullet_config": {
			"bullet_texture": Utils.get_atlas_texture(TESTING_ATLAS,22,10,64),
			"speed": 350,##in pixles per second
			"guidance": Enums.GuidanceType.SMART,
			"direct_damage": 10,#to whatever it hits, usually its intended target
			"fuse": Enums.Fuse.IMPACT,
		},
		"upgrade_options_config_keys": U_TWO,
	},
	T_A_ONE: {
		"icon_texture": Utils.get_atlas_texture(SHEET, sprites["icon"]["col"], sprites["icon"]["row"], sprites["cell"]),
		"tower_texture": Utils.get_atlas_texture(SHEET, sprites["towers"]["a_one"]["col"], sprites["towers"]["a_one"]["row"], sprites["cell"]),
		"display_name": "Fire Ant",
		"class": CLASS,
		"desc": "adds fire damage: burns its target over time",
		"targeting": Enums.TargetingType.CLOSEST,
		"can_see_camo": Enums.CanSeeCamo.CAN_SEE_CAMO,
		"min_range": 0,
		"max_range": 400,
		"fire_rate": 2,
		"shop_cost": 16,
		"bullet_config": {
			"bullet_texture": Utils.get_atlas_texture(VFX_ATLAS,0,1,64),
			"speed": 300,##in pixles per second
			"guidance": Enums.GuidanceType.SMART,
			"direct_damage": 5,#to whatever it hits, usually its intended target
			"fuse": Enums.Fuse.IMPACT,
			"status_effect": {
				"status_application": Enums.StatusApplication.DIRECT,
				"status_type": Enums.StatusEffectType.DOT,
				"status_duration": 4,
				"status_strength": 4
			},
		},
		"upgrade_options_config_keys": U_A_ONE,
	},
	T_A_TWO: {
		"icon_texture": Utils.get_atlas_texture(SHEET, sprites["icon"]["col"], sprites["icon"]["row"], sprites["cell"]),
		"tower_texture": Utils.get_atlas_texture(SHEET, sprites["towers"]["a_two"]["col"], sprites["towers"]["a_two"]["row"], sprites["cell"]),
		"display_name": "Burning Core",
		"class": CLASS,
		"desc": "longer, stronger burn",
		"targeting": Enums.TargetingType.CLOSEST,
		"can_see_camo": Enums.CanSeeCamo.CAN_SEE_CAMO,
		"min_range": 0,
		"max_range": 400,
		"fire_rate": 2,##design says Core only upgrades burn duration + damage
		"shop_cost": 20,
		"bullet_config": {
			"bullet_texture": Utils.get_atlas_texture(VFX_ATLAS,0,1,64),
			"speed": 300,##in pixles per second
			"guidance": Enums.GuidanceType.SMART,
			"direct_damage": 7,#to whatever it hits, usually its intended target
			"fuse": Enums.Fuse.IMPACT,
			"status_effect": {
				"status_application": Enums.StatusApplication.DIRECT,
				"status_type": Enums.StatusEffectType.DOT,
				"status_duration": 7,##was 4 - longer burn
				"status_strength": 7##was 4 - stronger burn
			},
		},
		"upgrade_options_config_keys": U_A_TWO,
	},
	T_A_THREE: {
		"icon_texture": Utils.get_atlas_texture(SHEET, sprites["icon"]["col"], sprites["icon"]["row"], sprites["cell"]),
		"tower_texture": Utils.get_atlas_texture(SHEET, sprites["towers"]["a_three"]["col"], sprites["towers"]["a_three"]["row"], sprites["cell"]),
		"display_name": "Living Furnace",
		"class": CLASS,
		"desc": "turns its shots into a stream of fire that burns everything in its sights",
		"targeting": Enums.TargetingType.CLOSEST,
		"can_see_camo": Enums.CanSeeCamo.CAN_SEE_CAMO,
		"min_range": 0,
		"max_range": 450,
		"fire_rate": 12,##stream of fire NOT possible yet (no beam weapon system),
		##approximated: very high fire rate with a burn DOT on every shot
		"shop_cost": 25,
		"bullet_config": {
			"bullet_texture": Utils.get_atlas_texture(VFX_ATLAS,0,1,64),
			"speed": 400,##in pixles per second
			"guidance": Enums.GuidanceType.SMART,
			"direct_damage": 2,#low per hit - the burn DOT does the work
			"fuse": Enums.Fuse.IMPACT,
			"status_effect": {
				"status_application": Enums.StatusApplication.DIRECT,
				"status_type": Enums.StatusEffectType.DOT,
				"status_duration": 4,
				"status_strength": 3
			},
		},
		"upgrade_options_config_keys": U_A_THREE,
	},
	T_B_ONE: {
		"icon_texture": Utils.get_atlas_texture(SHEET, sprites["icon"]["col"], sprites["icon"]["row"], sprites["cell"]),
		"tower_texture": Utils.get_atlas_texture(SHEET, sprites["towers"]["b_one"]["col"], sprites["towers"]["b_one"]["row"], sprites["cell"]),
		"display_name": "Bullet Ant",
		"class": CLASS,
		"desc": "major buff to fire rate",
		"targeting": Enums.TargetingType.FIRST,
		"can_see_camo": Enums.CanSeeCamo.CAN_SEE_CAMO,
		"min_range": 0,
		"max_range": 400,
		"fire_rate": 8,##4x the base ant - the whole point of this tier
		"shop_cost": 16,
		"bullet_config": {
			"bullet_texture": Utils.get_atlas_texture(VFX_ATLAS,0,1,64),
			"speed": 400,##in pixles per second
			"guidance": Enums.GuidanceType.LEAD,
			"direct_damage": 2,#low per hit - the fire rate does the work
			"fuse": Enums.Fuse.IMPACT,
		},
		"upgrade_options_config_keys": U_B_ONE,
	},
	#Termantator: pierce + manual target select are NOT possible yet (base_bullet
	#frees itself on the first enemy it hits, and there is no UI to pick a target),
	#so this tier is a stat boost only until those systems exist.
	T_B_TWO: {
		"icon_texture": Utils.get_atlas_texture(SHEET, sprites["icon"]["col"], sprites["icon"]["row"], sprites["cell"]),
		"tower_texture": Utils.get_atlas_texture(SHEET, sprites["towers"]["b_two"]["col"], sprites["towers"]["b_two"]["row"], sprites["cell"]),
		"display_name": "Termantator",
		"class": CLASS,
		"desc": "more pierce + can lock a chosen target (both pending)",
		"targeting": Enums.TargetingType.FIRST,
		"can_see_camo": Enums.CanSeeCamo.CAN_SEE_CAMO,
		"min_range": 0,
		"max_range": 425,
		"fire_rate": 10,
		"shop_cost": 20,
		"bullet_config": {
			"bullet_texture": Utils.get_atlas_texture(VFX_ATLAS,0,1,64),
			"speed": 450,##in pixles per second
			"guidance": Enums.GuidanceType.LEAD,
			"direct_damage": 3,#to whatever it hits, usually its intended target
			"fuse": Enums.Fuse.IMPACT,
		},
		"upgrade_options_config_keys": U_B_TWO,
	},
	T_B_THREE: {
		"icon_texture": Utils.get_atlas_texture(SHEET, sprites["icon"]["col"], sprites["icon"]["row"], sprites["cell"]),
		"tower_texture": Utils.get_atlas_texture(SHEET, sprites["towers"]["b_three"]["col"], sprites["towers"]["b_three"]["row"], sprites["cell"]),
		"display_name": "Ant-I Machine-Mortar",
		"class": CLASS,
		"desc": "slow-firing missile that blasts everything in its radius",
		"targeting": Enums.TargetingType.FIRST,
		"can_see_camo": Enums.CanSeeCamo.CAN_SEE_CAMO,
		"min_range": 0,
		"max_range": 450,
		"fire_rate": 0.5,##one missile every 2 seconds - the slow launcher
		"shop_cost": 25,
		"bullet_config": {
			"bullet_texture": Utils.get_atlas_texture(VFX_ATLAS,0,1,64),
			"speed": 150,##lobbed slowly like a mortar shell
			"guidance": Enums.GuidanceType.DUMB,##flies straight at the spot it was aimed at
			"direct_damage": 5,##unused by POINT fuses - aoe_damage is the payload
			"fuse": Enums.Fuse.POINT,##explodes when it reaches the aim point
			"aoe_radius": 80,##read by base_bullet: ExplosionArea shape
			"aoe_damage": 30,##read by base_bullet.explode() inside aoe_radius
		},
		"upgrade_options_config_keys": U_B_THREE,
	},
	#C path: the aura buffs / money-on-hit / timed ability from the design doc are
	#NOT possible yet (there is no tower-to-tower buff system and no ability system),
	#so these three are stat placeholders until those systems exist.
	#targeting is FIRST instead of BLANK STRONGEST on purpose: base_tower
	#_determine_selected_target reads i.health but enemies keep health in
	#_config["health"], so STRONGEST would error every frame.
	T_C_ONE: {
		"icon_texture": Utils.get_atlas_texture(SHEET, sprites["icon"]["col"], sprites["icon"]["row"], sprites["cell"]),
		"tower_texture": Utils.get_atlas_texture(SHEET, sprites["towers"]["c_one"]["col"], sprites["towers"]["c_one"]["row"], sprites["cell"]),
		"display_name": "Honeypot Ant",
		"class": CLASS,
		"desc": "boosts the fire rate of nearby towers (aura pending)",
		"targeting": Enums.TargetingType.FIRST,
		"can_see_camo": Enums.CanSeeCamo.CAN_SEE_CAMO,
		"min_range": 0,
		"max_range": 400,
		"fire_rate": 3,
		"shop_cost": 16,
		"bullet_config": {
			"bullet_texture": Utils.get_atlas_texture(VFX_ATLAS,0,1,64),
			"speed": 300,##in pixles per second
			"guidance": Enums.GuidanceType.LEAD,
			"direct_damage": 4,#to whatever it hits, usually its intended target
			"fuse": Enums.Fuse.IMPACT,
		},
		"upgrade_options_config_keys": U_C_ONE,
	},
	T_C_TWO: {
		"icon_texture": Utils.get_atlas_texture(SHEET, sprites["icon"]["col"], sprites["icon"]["row"], sprites["cell"]),
		"tower_texture": Utils.get_atlas_texture(SHEET, sprites["towers"]["c_two"]["col"], sprites["towers"]["c_two"]["row"], sprites["cell"]),
		"display_name": "Gracious Leader",
		"class": CLASS,
		"desc": "nearby towers earn extra money on hit; more range (money aura pending)",
		"targeting": Enums.TargetingType.FIRST,
		"can_see_camo": Enums.CanSeeCamo.CAN_SEE_CAMO,
		"min_range": 0,
		"max_range": 450,##the range half of this design tier IS possible, so it is in
		"fire_rate": 4,
		"shop_cost": 20,
		"bullet_config": {
			"bullet_texture": Utils.get_atlas_texture(VFX_ATLAS,0,1,64),
			"speed": 300,##in pixles per second
			"guidance": Enums.GuidanceType.LEAD,
			"direct_damage": 5,#to whatever it hits, usually its intended target
			"fuse": Enums.Fuse.IMPACT,
		},
		"upgrade_options_config_keys": U_C_TWO,
	},
	T_C_THREE: {
		"icon_texture": Utils.get_atlas_texture(SHEET, sprites["icon"]["col"], sprites["icon"]["row"], sprites["cell"]),
		"tower_texture": Utils.get_atlas_texture(SHEET, sprites["towers"]["c_three"]["col"], sprites["towers"]["c_three"]["row"], sprites["cell"]),
		"display_name": "Royal Cauldron",
		"class": CLASS,
		"desc": "ability: doubles fire rate of nearby towers (ability pending)",
		"targeting": Enums.TargetingType.FIRST,
		"can_see_camo": Enums.CanSeeCamo.CAN_SEE_CAMO,
		"min_range": 0,
		"max_range": 450,
		"fire_rate": 5,
		"shop_cost": 25,
		"bullet_config": {
			"bullet_texture": Utils.get_atlas_texture(VFX_ATLAS,0,1,64),
			"speed": 300,##in pixles per second
			"guidance": Enums.GuidanceType.LEAD,
			"direct_damage": 6,#to whatever it hits, usually its intended target
			"fuse": Enums.Fuse.IMPACT,
		},
		"upgrade_options_config_keys": U_C_THREE,
	},
}