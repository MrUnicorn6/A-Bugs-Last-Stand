extends Node
class TowerGuideOrTargetingEnums:
	enum TargetingTypes {Closest}
	enum GuidanceTypes {DUMB}


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
static func DUMBGuidance(bullet,target,proxThreshold,physicsDelta):
	if bullet.global_position.distance_to(target.global_position)<proxThreshold:
		bullet.explode()
	else:
		bullet.velocity = bullet.global_position.direction_to(target.global_position)*bullet.speed
		bullet.look_at(target.global_position)
		bullet.move_and_slide()
	

static func ClosestTargeting(Tower,PossibleTargets) -> int:
	var closest = 0
	for i in range(PossibleTargets):
		#compares possible targets to find the closest one
		if PossibleTargets[i].global_position.distance_to(Tower.global_position) < Tower.global_position.distance_to(closest.global_position):
			closest = i
	return closest
	#visual of looking at target
