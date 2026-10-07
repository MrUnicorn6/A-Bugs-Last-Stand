extends RefCounted
##Shared visuals: anything used by 2+ families (generic bullets, hit flashes, icons).
##Family files own their own sheets; this file owns the shared sheets.
##NOT a tower class — never goes in tower_registry class_files/towers_config.
##Consumers reference entries as "common/<key>" (e.g. "common/generic_bullet");
##the resolver splits on "/" and calls CommonAssets.sprite()/anim() directly.
##Same accessor shape as the per-family files (sprites dict + _built cache).

const Utils = preload("res://gameplay/towers/config/config_utils.gd")

const VFX_SHEET = preload("res://assets/vfx_atlas.png")
const SHARED_SHEET = preload("res://assets/tower_defense_tilesheet.png")

static var sprites := {
	"cell": 64,
	"vfx": {
		"hit_flash": {"type": "anim", "from": [0, 1], "to": [3, 1], "fps": 12},
	},
	"shared": {
		"generic_bullet": {"type": "sprite", "col": 22, "row": 10},
	},
}

##sheet picker: "vfx/..." and "shared/..." namespaces map to their sheets.
static func _sheet_for(top: String) -> Texture2D:
	if top == "vfx":
		return VFX_SHEET
	return SHARED_SHEET

static var _built := {}

static func sprite(path: String) -> Texture2D:
	if !_built.has(path):
		var def := Utils.lookup_sprite(sprites, path)
		assert(def["type"] == "sprite", "not a static sprite: " + path)
		_built[path] = Utils.build_sprite(
			_sheet_for(path.split("/")[0]), int(def["col"]), int(def["row"]), int(def.get("size", sprites["cell"])))
	return _built[path]

static func anim(path: String) -> SpriteFrames:
	if !_built.has(path):
		var def := Utils.lookup_sprite(sprites, path)
		assert(def["type"] == "anim", "not an animation: " + path)
		_built[path] = Utils.build_anim_entry(
			_sheet_for(path.split("/")[0]), def, int(sprites["cell"]))
	return _built[path]
