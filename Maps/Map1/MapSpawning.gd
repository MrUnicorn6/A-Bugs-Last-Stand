extends TileMapLayer


func getSpawnScriptNode()->Node:
	return $enemiesSpawning


'''
this is depricated stuff, i was thinking of moving the entire map, but instead
it might be better to move a viewport within a map
'''



func _ready() -> void:
	z_index = -10
	#doRound()
	


	
	
