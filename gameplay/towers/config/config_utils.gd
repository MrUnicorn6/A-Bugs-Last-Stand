extends RefCounted
##shared helpers for the tower config files (and the Loader itself).
##this lives here rather than in gameplay_objects_loader.gd on purpose:
##the config files preload this, the Loader preloads the config files,
##so pointing config files back at the Loader would make a preload cycle.

const Enums = preload("res://main/enums.gd")

#atlases
const TESTING_ATLAS = preload("res://assets/tower_defense_tilesheet.png")
const BUG_ATLAS = preload("res://assets/depricated Bug Atlas.png")

##cuts a single cell out of an atlas sheet.
##same helper that used to live in gameplay_objects_loader.gd
##col/row are 0-indexed: (0,0) is the top-left cell. region = (col*size, row*size).
##convention note: family sprite sections use 1-based coords in prose ("icon at 1,1"
##means second cell in, second row down). keep one convention per file, don't mix.
static func get_atlas_texture(atlas: Texture2D,col: int,row: int,cell_size) -> Texture2D:
	var tex := AtlasTexture.new()
	tex.atlas = atlas
	var rownumb = row*cell_size
	var colnumb = col*cell_size
	tex.region = Rect2(
		colnumb,
		rownumb,
		cell_size,
		cell_size)
	return tex

##thin wrap of get_atlas_texture for the per-family asset files,
##so they never touch AtlasTexture directly.
static func build_sprite(atlas: Texture2D, col: int, row: int, cell_size: int) -> Texture2D:
	return get_atlas_texture(atlas, col, row, cell_size)

##expands a "from"/"to" cell range into an explicit cell list (inclusive).
##row-fixed: same row, walk columns. column-fixed: same column, walk rows.
##diagonals are rejected (assert) — a typo should fail loud, not make an L-shape.
##any entry can skip ranges entirely and declare "cells" explicitly instead
##(for non-sequential cycles like [[2,1],[2,2],[2,1]]).
static func expand_range(from_cell: Array, to_cell: Array) -> Array:
	assert(from_cell[0] == to_cell[0] or from_cell[1] == to_cell[1],
		"range must share a row or a column: " + str(from_cell) + " -> " + str(to_cell))
	var cells := []
	if from_cell[1] == to_cell[1]: # same row: walk columns
		for col in range(from_cell[0], to_cell[0] + 1):
			cells.append([col, from_cell[1]])
	else: # same column: walk rows
		for row in range(from_cell[1], to_cell[1] + 1):
			cells.append([from_cell[0], row])
	return cells

##builds a SpriteFrames (single "default" animation) from an explicit cell list.
static func build_anim(atlas: Texture2D, cells: Array, fps: float, cell_size: int) -> SpriteFrames:
	var frames := SpriteFrames.new()
	frames.add_animation("default")
	frames.set_animation_speed("default", fps)
	for cell in cells:
		frames.add_frame("default", get_atlas_texture(atlas, cell[0], cell[1], cell_size))
	return frames

##resolves one sprite entry (either "cells" or "from"/"to" form) into a SpriteFrames.
##entry: the per-thing dict; fallback_cell: the family's "cell" default for "size".
static func build_anim_entry(atlas: Texture2D, entry: Dictionary, fallback_cell: int) -> SpriteFrames:
	var cells: Array = entry["cells"] if entry.has("cells") else expand_range(entry["from"], entry["to"])
	return build_anim(atlas, cells, float(entry.get("fps", 8)), int(entry.get("size", fallback_cell)))

##walks a sprites dict down an "a/b/c" path. asserts on missing keys.
##centralized so every family/common asset file shares one path-walker;
##pass the file's own `sprites` dict in (dictionaries pass by reference, zero cost).
static func lookup_sprite(sprites: Dictionary, path: String) -> Dictionary:
	var node: Dictionary = sprites
	var parts := path.split("/")
	for i in parts.size():
		var part: String = parts[i]
		assert(node.has(part), "sprite path not found: " + path)
		if i == parts.size() - 1:
			assert(node[part] is Dictionary, "sprite path is not an entry: " + path)
			return node[part]
		assert(node[part] is Dictionary, "sprite path dead-ends at: " + part)
		node = node[part]
	return {} # unreachable, asserts above

##lazy-build + cache a static sprite. pass the file's own `sprites` dict and
##`_built` cache (dicts pass by reference, so the cache write lands in the caller).
##asserts the entry is a sprite, not an anim.
static func fetch_sprite(sprites: Dictionary, cache: Dictionary, atlas: Texture2D, path: String) -> Texture2D:
	if !cache.has(path):
		var def := lookup_sprite(sprites, path)
		assert(def["type"] == "sprite", "not a static sprite: " + path)
		cache[path] = build_sprite(
			atlas, int(def["col"]), int(def["row"]), int(def.get("size", sprites["cell"])))
	return cache[path]

##lazy-build + cache an animation. same pass-by-reference cache pattern as fetch_sprite.
static func fetch_anim(sprites: Dictionary, cache: Dictionary, atlas: Texture2D, path: String) -> SpriteFrames:
	if !cache.has(path):
		var def := lookup_sprite(sprites, path)
		assert(def["type"] == "anim", "not an animation: " + path)
		cache[path] = build_anim_entry(atlas, def, int(sprites["cell"]))
	return cache[path]


## --- tower tree bake --------------------------------------------------------
##family files author a 12-slot tree of *deltas*. bake_family() walks trunk then
##a/b/c, deep-merges each overlay onto its parent, stamps textures / upgrade
##keys / identity, and returns the flat {tower_key: full config} dict the rest
##of the game already reads (Loader.towers_config["ants"]["ant_tower"] etc).
##
##spec keys:
##  insect  String     key prefix ("ant" -> "ant_tower", "ant_a_one", ...)
##  class   String     registry class ("ants"), written onto every tower
##  sheet   Texture2D  family art; icon + tower_texture come from sprites
##  sprites Dictionary same shape as BLANK_CONFIG (icon + towers/{slot})
##  defaults Dictionary  tower-level fields for trunk[0]'s parent
##  bullet  Dictionary  default bullet_config (use "bullet" in overlays too)
##  special Dictionary  optional overlay on SPECIAL_DEFAULTS
##  trunk, a, b, c  each an Array of 3 overlay dicts
##
##"special" is copied onto every baked tower so every insect has the same
##shape. combat does not read it yet — it is the hook for pierce / beam /
##aura / grab / abilities. overlay a field to change it down the tree.

const SLOT_TRUNK := ["tower", "one", "two"]
const SLOT_A := ["a_one", "a_two", "a_three"]
const SLOT_B := ["b_one", "b_two", "b_three"]
const SLOT_C := ["c_one", "c_two", "c_three"]

const SPECIAL_DEFAULTS := {
	"weapon": Enums.WeaponType.BULLET,
	"pierce": 0, ## extra enemies a shot can pass through; 0 = die on first hit
	"select_target": false, ## player can lock a target (Termantator)
	"aura": Enums.AuraType.NONE,
	"aura_enabled": true,
	"aura_strength": 1.0,
	"aura_range": -1.0,
	"ability": Enums.AbilityType.NONE,
	"money_on_hit": 0.0, ## base cash per bullet hit; nearby aura multipliers can scale it
}

static var DEFAULT_TOWER_CONFIG: Dictionary = {
	"min_range": 0,
	"targeting_options": [Enums.TargetingType.FIRST, Enums.TargetingType.STRONGEST],
	"turn_speed": 5.0,
	"move_speed": 60.0,
	"fire_arc": PI/4,
	"bullet_config": {
		"lifetime": 3.0,
	},
	"special": SPECIAL_DEFAULTS.duplicate(true),
}

static func deep_merge(base: Dictionary, overlay: Dictionary) -> Dictionary:
	var out: Dictionary = base.duplicate(true)
	for k in overlay.keys():
		if overlay[k] is Dictionary and out.has(k) and out[k] is Dictionary:
			out[k] = deep_merge(out[k], overlay[k])
		else:
			out[k] = overlay[k]
	return out

static func _tower_key(insect: String, slot: String) -> String:
	return insect + "_" + slot

static func _next_upgrade_keys(insect: String, path: String, tier: int) -> Array:
	if path == "trunk":
		if tier == 0:
			return [_tower_key(insect, "one")]
		if tier == 1:
			return [_tower_key(insect, "two")]
		return [
			_tower_key(insect, "a_one"),
			_tower_key(insect, "b_one"),
			_tower_key(insect, "c_one"),
		]
	var slots: Array = SLOT_A if path == "a" else (SLOT_B if path == "b" else SLOT_C)
	if tier >= slots.size() - 1:
		return []
	return [_tower_key(insect, slots[tier + 1])]

static func _entry_texture(sheet: Texture2D, sprites: Dictionary, entry: Dictionary) -> Texture2D:
	return get_atlas_texture(
		sheet,
		int(entry["col"]),
		int(entry["row"]),
		int(entry.get("size", sprites["cell"]))
	)

##overlays may say "bullet": {...} as a shorthand for bullet_config.
static func _normalize_overlay(overlay: Dictionary) -> Dictionary:
	var o: Dictionary = overlay.duplicate(true)
	if o.has("bullet"):
		var bullet_overlay: Dictionary = o["bullet"]
		o.erase("bullet")
		if o.has("bullet_config") and o["bullet_config"] is Dictionary:
			o["bullet_config"] = deep_merge(o["bullet_config"], bullet_overlay)
		else:
			o["bullet_config"] = bullet_overlay
	return o

static func bake_family(spec: Dictionary) -> Dictionary:
	var insect: String = spec["insect"]
	var class_key: String = spec["class"]
	var sheet: Texture2D = spec["sheet"]
	var sprites: Dictionary = spec["sprites"]
	assert(spec.has("trunk") and spec.has("a") and spec.has("b") and spec.has("c"),
		"bake_family needs trunk/a/b/c arrays for " + insect)
	assert(spec["trunk"].size() == 3 and spec["a"].size() == 3
		and spec["b"].size() == 3 and spec["c"].size() == 3,
		"each branch must have 3 tiers for " + insect)

	var parent: Dictionary = deep_merge(DEFAULT_TOWER_CONFIG.duplicate(true), {
		"class": class_key,
		"bullet_config": deep_merge(
			DEFAULT_TOWER_CONFIG["bullet_config"].duplicate(true),
			spec.get("bullet", {}).duplicate(true)
		),
		"special": deep_merge(SPECIAL_DEFAULTS.duplicate(true), spec.get("special", {})),
	})
	parent = deep_merge(parent, spec.get("defaults", {}))

	var baked := {}
	parent = _bake_branch(baked, spec, parent, "trunk", SLOT_TRUNK, spec["trunk"])
	_bake_branch(baked, spec, parent, "a", SLOT_A, spec["a"])
	_bake_branch(baked, spec, parent, "b", SLOT_B, spec["b"])
	_bake_branch(baked, spec, parent, "c", SLOT_C, spec["c"])
	return baked

static func _bake_branch(
		baked: Dictionary,
		spec: Dictionary,
		parent: Dictionary,
		path: String,
		slots: Array,
		overlays: Array) -> Dictionary:
	var insect: String = spec["insect"]
	var class_key: String = spec["class"]
	var sheet: Texture2D = spec["sheet"]
	var sprites: Dictionary = spec["sprites"]
	var current: Dictionary = parent
	for i in overlays.size():
		var slot: String = slots[i]
		current = _bake_node(
			current,
			overlays[i],
			insect,
			class_key,
			sheet,
			sprites,
			slot,
			path,
			i,
			_next_upgrade_keys(insect, path, i)
		)
		baked[_tower_key(insect, slot)] = current
	return current

static func _bake_node(
		parent: Dictionary,
		overlay: Dictionary,
		insect: String,
		class_key: String,
		sheet: Texture2D,
		sprites: Dictionary,
		slot: String,
		path: String,
		tier: int,
		next_keys: Array) -> Dictionary:
	var o: Dictionary = _normalize_overlay(overlay)
	var special_overlay := {}
	if o.has("special"):
		special_overlay = o["special"]
		o.erase("special")
	var cfg: Dictionary = deep_merge(parent, o)
	cfg["class"] = class_key
	assert(sprites.has("icon"), "sprites.icon missing for " + insect)
	assert(sprites.has("towers") and sprites["towers"].has(slot),
		"sprites.towers." + slot + " missing for " + insect)
	cfg["icon_texture"] = _entry_texture(sheet, sprites, sprites["icon"])
	cfg["tower_texture"] = _entry_texture(sheet, sprites, sprites["towers"][slot])
	if cfg.has("bullet_config") and cfg["bullet_config"] is Dictionary:
		if !cfg["bullet_config"].has("bullet_texture") and sprites.has("bullet_one"):
			cfg["bullet_config"]["bullet_texture"] = _entry_texture(
				sheet, sprites, sprites["bullet_one"])
	cfg["special"] = deep_merge(parent.get("special", SPECIAL_DEFAULTS.duplicate(true)), special_overlay)
	cfg["upgrade_options_config_keys"] = next_keys
	cfg["tower_key"] = _tower_key(insect, slot)
	cfg["slot"] = slot
	cfg["path"] = path
	cfg["tier"] = tier
	return cfg
