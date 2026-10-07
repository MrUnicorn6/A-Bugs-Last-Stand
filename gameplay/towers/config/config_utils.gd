extends RefCounted
##shared helpers for the tower config files (and the Loader itself).
##this lives here rather than in gameplay_objects_loader.gd on purpose:
##the config files preload this, the Loader preloads the config files,
##so pointing config files back at the Loader would make a preload cycle.

#atlases
const TESTING_ATLAS = preload("res://assets/tower_defense_tilesheet.png")
const BUG_ATLAS = preload("res://assets/bug_atlas.png")

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
