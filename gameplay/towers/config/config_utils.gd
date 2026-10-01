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
