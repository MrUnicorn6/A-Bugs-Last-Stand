extends RefCounted
##shared helpers for the tower config files (and the loader itself).
##this lives here rather than in gameplay_objects_loader.gd on purpose:
##the config files preload this, the loader preloads the config files,
##so pointing config files back at the loader would make a preload cycle.

#atlases
const TestingAtlas = preload("res://Assets/towerDefense_tilesheet.png")
const BugAtlas = preload("res://Assets/BugAtlas.png")

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
