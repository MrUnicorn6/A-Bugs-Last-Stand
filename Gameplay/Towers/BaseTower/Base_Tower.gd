extends StaticBody2D


class_name Tower


const Enums = preload("res://Main/ENUMS.gd")
const base_bullet = preload("res://Gameplay/Towers/BaseTower/base_bullet.tscn")

@export var _config:Dictionary

#in use by this script for temporary thingies
var draw_range = false
var upgrade_count:int = 0
var fire_rate_cooldown:float = 0
var possible_targets:Array[Node] = [] ##constantly changing arr of targets
var selected_target:Node = null ##for holding a target seperate from possibleTargets
func _draw() -> void:
	if draw_range:
		draw_circle(Vector2(0,0),_config["max_range"],Color(0,0,0,0.25),true)
	
func set_config(config_to_be_set_to:Dictionary):
	#print("TRYING TO SETTING CONFIG, BUT MAY NOT UPDATING PROPERLY")
	_config = config_to_be_set_to
	$TargetingRange/TargetingHitbox.shape.radius = _config["max_range"]
	$Sprite.texture = _config["tower_texture"]
	


func _physics_process(delta: float) -> void:
	if possible_targets.is_empty() || possible_targets.size()==0:
		return
	if selected_target not in possible_targets && !possible_targets.is_empty():
		selected_target = possible_targets[0]
	if !is_instance_valid(selected_target):
		selected_target = null
	_determine_selected_target()

	if fire_rate_cooldown > 0:
		fire_rate_cooldown -= delta
	if (selected_target != null)&& (fire_rate_cooldown<=0):
		_shoot()
		fire_rate_cooldown = 1.0 / _config["fire_rate"]
func _shoot():
	var temp_bullet = base_bullet.instantiate()
	temp_bullet.set_config(_config["bullet_config"])
	temp_bullet.global_position = $BulletSpawnPoint.global_position
	temp_bullet.shoot_at_target(selected_target,selected_target.global_position)
	
	$BulletContainer.add_child(temp_bullet)

func _on_targeting_range_body_entered(body: Node2D) -> void:
	#print("target entered, ",body.get_groups()," Range is ",_config["max_range"]," actual range is ",$TargetingRange/TargetingHitbox.shape.radius,
	#" also possible tgts is ",possible_targets.size())
	if _config["can_see_camo"] == Enums.CanSeeCamo.CANSEECAMO:
		if body.is_in_group("ENEMY"):
			possible_targets.append(body)
	elif _config["can_see_camo"] == Enums.CanSeeCamo.CANNOTSEECAMO:
		if body.is_in_group("ENEMY") && !body.is_in_group("CAMO"):
			possible_targets.append(body)


func _on_targeting_range_body_exited(body: Node2D) -> void:
	if body in possible_targets:
		possible_targets.remove_at(possible_targets.find(body))
	if body == selected_target:
		selected_target = null


## to manually re check each enemy in range, for when a tower is
##upgraded or placed.
func update_possible_targets():
	var bodies = $'TargetingRange'.get_overlapping_bodies()
	for i in bodies:
		if _config["can_see_camo"] == Enums.CanSeeCamo.CANSEECAMO:
			if i.is_in_group("ENEMY"):
				possible_targets.append(i)
		elif _config["can_see_camo"] == Enums.CanSeeCamo.CANNOTSEECAMO:
			if i.is_in_group("ENEMY") && !i.is_in_group("CAMO"):
				possible_targets.append(i)


func _determine_selected_target()->void:
	if _config["targeting"] == Enums.TargetingTypes.CLOSEST:
		var closest = possible_targets[0]
		for i in possible_targets:
			if i.global_position.distance_to(global_position) < global_position.distance_to(closest.global_position):
				closest = i
		selected_target = closest


	elif _config["targeting"] == Enums.TargetingTypes.STRONGEST:
		var strongest = possible_targets[0]
		for i in possible_targets:
			if i.health > strongest.health:
				strongest = i
		selected_target = strongest


	elif _config["targeting"] == Enums.TargetingTypes.FIRST:
			selected_target = possible_targets[0]


	elif _config["targeting"] == Enums.TargetingTypes.LAST:
			var Last = possible_targets[0]
			print("LAST TARGETING METHOD NOT IMPLEMENTED ")
			selected_target = Last
##@depricated: THIS IS A SHITTY METHOD, FIX IT
func _on_clicked_on_detector_gui_input(event: InputEvent) -> void:
	
	if event is InputEventMouseButton and event.button_mask==0:
		print("WHAT THE FUCK IS THIS PEICE OF SHI AH AH METHOD Tower.Onclicked")
		#get_node("/root/Main/UI").changeToUpgradeScreen(self,_config["upgrades"])
	pass
