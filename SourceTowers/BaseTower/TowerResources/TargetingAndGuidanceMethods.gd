extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func GOLISGuidance(Tower,PossibleTargets) -> int:
	var closest = 0
	for i in range(PossibleTargets):
		#compares possible targets to find the closest one
		if PossibleTargets[i].global_position.distance_to(Tower.global_position) < Tower.global_position.distance_to(closest.global_position):
			closest = i
	return closest
	#visual of looking at target
