extends StaticBody2D


class_name BaseTower


const Enums = preload("res://main/enums.gd")
const BASE_BULLET = preload("res://gameplay/towers/base_tower/base_bullet.tscn")


@export var _config:Dictionary

#in use by this script for temporary thingies
var draw_range = false
var upgrade_count:int = 0
var fire_rate_cooldown:float = 0
var possible_targets:Array[Node] = [] ##constantly changing arr of targets
var selected_target:Node = null ##for holding a target seperate from possible_targets
func _draw() -> void:
	if draw_range:
		draw_circle(Vector2(0,0),_config["max_range"],Color(0,0,0,0.25),true)
	
func set_config(config_to_be_set_to:Dictionary):
	#print("TRYING TO SETTING CONFIG, BUT MAY NOT UPDATING PROPERLY")
	_config = config_to_be_set_to
	$TargetingRange/TargetingHitbox.shape.radius = _config["max_range"]
	$Sprite.texture = _config["tower_texture"]

func get_config()-> Dictionary:
	return _config


func _physics_process(delta: float) -> void:
	if possible_targets.is_empty() || possible_targets.size()==0:
		return
	if selected_target not in possible_targets && !possible_targets.is_empty():
		selected_target = possible_targets[0]
	if !is_instance_valid(selected_target):
		selected_target = null
	_determine_selected_target()
	if selected_target == null || !is_instance_valid(selected_target):
		return
	look_at(_get_aim_point())

	if fire_rate_cooldown > 0:
		fire_rate_cooldown -= delta
	if (selected_target != null)&& (fire_rate_cooldown<=0):
		_shoot()
		fire_rate_cooldown = 1.0 / _config["fire_rate"]
func _shoot():
	var temp_bullet = BASE_BULLET.instantiate()
	temp_bullet.set_config(_config["bullet_config"])
	temp_bullet.global_position = $BulletSpawnPoint.global_position
	temp_bullet.shoot_at_target(selected_target,selected_target.global_position)
	
	$BulletContainer.add_child(temp_bullet)

func _on_targeting_range_body_entered(body: Node2D) -> void:
	#print("target entered, ",body.get_groups()," Range is ",_config["max_range"]," actual range is ",$TargetingRange/TargetingHitbox.shape.radius,
	#" also possible tgts is ",possible_targets.size())
	if _config["can_see_camo"] == Enums.CanSeeCamo.CAN_SEE_CAMO:
		if body.is_in_group("ENEMY"):
			possible_targets.append(body)
	elif _config["can_see_camo"] == Enums.CanSeeCamo.CANNOT_SEE_CAMO:
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
		if _config["can_see_camo"] == Enums.CanSeeCamo.CAN_SEE_CAMO:
			if i.is_in_group("ENEMY"):
				possible_targets.append(i)
		elif _config["can_see_camo"] == Enums.CanSeeCamo.CANNOT_SEE_CAMO:
			if i.is_in_group("ENEMY") && !i.is_in_group("CAMO"):
				possible_targets.append(i)


func _determine_selected_target()->void:
	if _config["targeting"] == Enums.TargetingType.CLOSEST:
		var closest = possible_targets[0]
		for i in possible_targets:
			if i.global_position.distance_to(global_position) < global_position.distance_to(closest.global_position):
				closest = i
		selected_target = closest


	elif _config["targeting"] == Enums.TargetingType.STRONGEST:
		var strongest = possible_targets[0]
		for i in possible_targets:
			if i.health > strongest.health:
				strongest = i
		selected_target = strongest


	elif _config["targeting"] == Enums.TargetingType.FIRST:
			selected_target = possible_targets[0]


	elif _config["targeting"] == Enums.TargetingType.LAST:
			var last_target = possible_targets[0]
			print("LAST TARGETING METHOD NOT IMPLEMENTED ")
			selected_target = last_target
##@depricated: THIS IS A SHITTY METHOD, FIX IT
func _on_clicked_on_detector_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_mask==0:
		print("THIS GETNODE ROOT PISSES ME OFF")
		get_node("/root/Main").user_interface.get_upgrade_panel().set_to_upgrades_for_tower(self)

##Lead-intercept solver, owned here so the tower can aim its barrel at the
##predicted point every frame. Mostly used by BaseBullet.shoot_at_target()
##at fire-time via BaseTower.solve_intercept() — static so the bullet can
##call it without a tower instance (avoids a preload cycle with base_bullet.tscn).
##shooter_pos: where the bullet spawns (tower uses BulletSpawnPoint so the
##barrel angle matches the bullet flight angle).
##dumbpoint: where the target is RIGHT NOW. Falls back to dumbpoint (plain
##DUMB aim) when no valid intercept exists.
static func solve_intercept(shooter_pos: Vector2, dumbpoint: Vector2, target_velocity: Vector2, bullet_speed: float) -> Vector2:
	# arrow from shooter to where the target is right now
	var vector_to_target := dumbpoint - shooter_pos
	# squared-out form of |vector_to_target + target_velocity*t| = bullet_speed*t
	var quadratic_A := target_velocity.dot(target_velocity) - bullet_speed * bullet_speed
	var quadratic_B := 2.0 * vector_to_target.dot(target_velocity)
	var quadratic_C := vector_to_target.dot(vector_to_target)
	# near-linear case (target ~stationary): plain time-of-flight
	if absf(quadratic_A) < 0.001:
		var straight_line_time := vector_to_target.length() / maxf(bullet_speed, 0.001)
		return dumbpoint + target_velocity * straight_line_time
	# no real roots: bullet can never catch the target
	var discriminant := quadratic_B * quadratic_B - 4.0 * quadratic_A * quadratic_C
	if discriminant < 0.0:
		return dumbpoint
	var square_root := sqrt(discriminant)
	var impact_time_option_1 := (-quadratic_B + square_root) / (2.0 * quadratic_A)
	var impact_time_option_2 := (-quadratic_B - square_root) / (2.0 * quadratic_A)
	var time_to_impact := -1.0
	if impact_time_option_1 > 0.0 and impact_time_option_2 > 0.0:
		time_to_impact = minf(impact_time_option_1, impact_time_option_2)
	elif impact_time_option_1 > 0.0:
		time_to_impact = impact_time_option_1
	elif impact_time_option_2 > 0.0:
		time_to_impact = impact_time_option_2
	else:
		return dumbpoint
	return dumbpoint + target_velocity * time_to_impact


##Where the barrel should point this frame. For LEAD guidance this is the
##predicted intercept (same math the bullet uses at fire-time); for every
##other guidance type it's just the target's current position.
func _get_aim_point() -> Vector2:
	if _config["bullet_config"]["guidance"] != Enums.GuidanceType.LEAD:
		return selected_target.global_position
	var aim_velocity := Vector2.ZERO
	if selected_target.has_method("get_current_velocity"):
		aim_velocity = selected_target.get_current_velocity()
	elif selected_target is CharacterBody2D:
		aim_velocity = (selected_target as CharacterBody2D).velocity
	return solve_intercept(
		$BulletSpawnPoint.global_position,
		selected_target.global_position,
		aim_velocity,
		_config["bullet_config"]["speed"]
	)
	
