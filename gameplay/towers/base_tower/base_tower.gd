extends StaticBody2D


class_name BaseTower


const Enums = preload("res://main/enums.gd")
const BASE_BULLET = preload("res://gameplay/towers/base_tower/base_bullet.tscn")


@export var _config:Dictionary

var move_speed: float = 60.0
var move_finish_distance: float = 12.0
var navigation_agent: NavigationAgent2D = null

#in use by this script for temporary thingies
var draw_range = false
var upgrade_count:int = 0
var fire_rate_cooldown:float = 0
var possible_targets:Array[Node] = [] ##constantly changing arr of targets
var selected_target:Node = null ##for holding a target seperate from possible_targets
var is_moving: bool = false
var can_fire: bool = true
var move_target_position: Vector2 = Vector2.ZERO
var move_target_set: bool = false
var move_target_mode: bool = false

func _draw() -> void:
	if draw_range:
		draw_circle(Vector2(0,0),_config["max_range"],Color(0,0,0,0.25),true)
	
func set_config(config_to_be_set_to:Dictionary):
	#print("TRYING TO SETTING CONFIG, BUT MAY NOT UPDATING PROPERLY")
	_config = config_to_be_set_to.duplicate(true)
	move_speed = maxf(float(_config.get("move_speed", 60.0)), 0.0)
	$TargetingRange/TargetingHitbox.shape.radius = _config["max_range"]
	$Sprite.texture = _config["tower_texture"]
	if navigation_agent != null:
		navigation_agent.target_position = move_target_position

func get_config()-> Dictionary:
	return _config

func set_selected_target(target: Node) -> void:
	selected_target = target

func set_targeting_type(targeting_type: int) -> void:
	if get_targeting_options().has(targeting_type):
		_config["targeting"] = targeting_type

func get_targeting_options() -> Array[int]:
	var valid_types: Array[int] = [
		Enums.TargetingType.FIRST,
		Enums.TargetingType.STRONGEST,
		Enums.TargetingType.LAST,
		Enums.TargetingType.CLOSEST,
	]
	var options: Array[int] = []
	var configured_options: Variant = _config.get("targeting_options", [
		Enums.TargetingType.FIRST,
		Enums.TargetingType.STRONGEST,
	])
	if configured_options is Array:
		for configured_type in configured_options:
			var targeting_type: int = int(configured_type)
			if valid_types.has(targeting_type) and !options.has(targeting_type):
				options.append(targeting_type)
	var current_type: int = int(_config.get("targeting", Enums.TargetingType.FIRST))
	if valid_types.has(current_type) and !options.has(current_type):
		options.append(current_type)
	if options.is_empty():
		options = [Enums.TargetingType.FIRST, Enums.TargetingType.STRONGEST]
	return options

func cycle_targeting_type() -> int:
	var types: Array[int] = get_targeting_options()
	var current: int = int(_config.get("targeting", Enums.TargetingType.FIRST))
	var index: int = types.find(current)
	if index < 0:
		index = 0
	else:
		index = (index + 1) % types.size()
	set_targeting_type(types[index])
	return types[index]

func set_move_target_position(position: Vector2) -> void:
	move_target_position = position
	move_target_set = true
	move_target_mode = false
	is_moving = true
	can_fire = false
	_ensure_navigation_agent()
	navigation_agent.target_position = position

func clear_move_target_position() -> void:
	move_target_set = false
	move_target_mode = false
	is_moving = false
	can_fire = true
	if navigation_agent != null:
		navigation_agent.target_position = global_position

func _ensure_navigation_agent() -> void:
	if navigation_agent != null:
		return
	if has_node("NavigationAgent2D"):
		navigation_agent = $NavigationAgent2D
		return
	navigation_agent = NavigationAgent2D.new()
	navigation_agent.name = "NavigationAgent2D"
	navigation_agent.path_desired_distance = 24.0
	navigation_agent.target_desired_distance = 12.0
	add_child(navigation_agent)

func _update_movement(delta: float) -> bool:
	if !move_target_set or !is_moving:
		return false
	_ensure_navigation_agent()
	navigation_agent.target_position = move_target_position
	var target_distance: float = global_position.distance_to(move_target_position)
	if target_distance <= move_finish_distance:
		clear_move_target_position()
		return false
	var next_step: Vector2 = move_target_position
	if navigation_agent.get_current_navigation_path().size() > 0:
		next_step = navigation_agent.get_next_path_position()
	elif navigation_agent.is_target_reachable():
		next_step = move_target_position
	var direction: Vector2 = global_position.direction_to(next_step)
	if direction.length_squared() <= 0.0001:
		direction = global_position.direction_to(move_target_position)
	if direction.length_squared() <= 0.0001:
		clear_move_target_position()
		return false
	var desired_rotation: float = direction.angle()
	var angle_delta: float = wrapf(desired_rotation - rotation, -PI, PI)
	var turn_speed: float = maxf(float(_config.get("turn_speed", 5.0)), 0.0)
	var max_turn: float = turn_speed * delta
	if absf(angle_delta) > max_turn:
		rotation += signf(angle_delta) * max_turn
		return true
	rotation = desired_rotation
	global_position += Vector2.RIGHT.rotated(rotation) * move_speed * delta
	if global_position.distance_to(move_target_position) <= move_finish_distance:
		clear_move_target_position()
	return true

func set_moving_state(moving: bool) -> void:
	is_moving = moving
	can_fire = !moving

func set_can_fire(allowed: bool) -> void:
	can_fire = allowed
	if !can_fire:
		fire_rate_cooldown = 0.0

func _can_fire_now() -> bool:
	if !can_fire:
		return false
	if is_moving:
		return false
	if selected_target == null || !is_instance_valid(selected_target):
		return false
	return _target_is_in_firing_arc(selected_target)

func _target_is_in_firing_arc(target: Node) -> bool:
	if target == null || !is_instance_valid(target):
		return false
	var aim_point: Vector2 = _get_aim_point()
	var target_vector: Vector2 = aim_point - global_position
	if target_vector.length_squared() <= 0.0001:
		return true
	var fire_arc: float = maxf(float(_config.get("fire_arc", PI)), 0.0)
	if fire_arc <= 0.0:
		return true
	var turret_forward: Vector2 = Vector2.RIGHT.rotated(rotation)
	var angle_to_target: float = absf(turret_forward.angle_to(target_vector.normalized()))
	if angle_to_target > fire_arc:
		return false
	var space_state = get_world_2d().direct_space_state
	if space_state == null:
		return true
	var query := PhysicsRayQueryParameters2D.create(global_position, aim_point, 0, [self])
	query.collide_with_areas = false
	var result = space_state.intersect_ray(query)
	if result.is_empty():
		return true
	return result.get("collider", null) == target

func set_aura_state(active: bool, aura_type: int = Enums.AuraType.NONE, aura_strength: float = 1.0, aura_range: float = -1.0) -> void:
	var special: Dictionary = _config.get("special", {}).duplicate(true)
	if !active or aura_type == Enums.AuraType.NONE:
		special["aura"] = Enums.AuraType.NONE
		special["aura_enabled"] = false
		special["aura_strength"] = 1.0
	else:
		special["aura"] = aura_type
		special["aura_enabled"] = true
		special["aura_strength"] = maxf(float(aura_strength), 0.0)
		if aura_range >= 0.0:
			special["aura_range"] = float(aura_range)
		else:
			special["aura_range"] = float(_config.get("max_range", 0.0))
	_config["special"] = special

func _get_nearby_towers_in_range(override_range: float = -1.0) -> Array:
	var towers: Array = []
	if get_tree() == null:
		return towers
	var check_range: float = override_range
	if check_range < 0.0:
		check_range = float(_config.get("max_range", 0.0))
	for tower in get_tree().get_nodes_in_group("TOWER"):
		if tower == self or !tower.has_method("get_config"):
			continue
		var tower_config: Dictionary = tower.get_config()
		var range_limit: float = float(tower_config.get("max_range", check_range))
		if global_position.distance_to(tower.global_position) <= range_limit:
			towers.append(tower)
	return towers

func _get_aura_multiplier(aura_type: int) -> float:
	var multiplier: float = 1.0
	if get_tree() == null:
		return multiplier
	for tower in get_tree().get_nodes_in_group("TOWER"):
		if tower == self or !tower.has_method("get_config"):
			continue
		var other_special: Dictionary = tower.get_config().get("special", {})
		if int(other_special.get("aura", Enums.AuraType.NONE)) != aura_type:
			continue
		if !bool(other_special.get("aura_enabled", true)):
			continue
		var range_limit: float = float(other_special.get("aura_range", tower.get_config().get("max_range", 0.0)))
		if global_position.distance_to(tower.global_position) > range_limit:
			continue
		multiplier *= maxf(float(other_special.get("aura_strength", 1.0)), 0.0)
	return multiplier

func _get_effective_fire_rate() -> float:
	var rate: float = float(_config.get("fire_rate", 1.0))
	var multiplier: float = _get_aura_multiplier(Enums.AuraType.FIRE_RATE)
	var special: Dictionary = _config.get("special", {})
	var ability: int = int(special.get("ability", Enums.AbilityType.NONE))
	if ability == Enums.AbilityType.DOUBLE_NEARBY_FIRE_RATE and _get_nearby_towers_in_range().size() > 0:
		multiplier *= 2.0
	return maxf(rate * multiplier, 0.1)

func get_money_bonus() -> int:
	var base_bonus: float = float(_config.get("special", {}).get("money_on_hit", 0.0))
	var multiplier: float = _get_aura_multiplier(Enums.AuraType.MONEY_ON_HIT)
	return int(round(base_bonus * multiplier))


func _physics_process(delta: float) -> void:
	if _update_movement(delta):
		return
	_prune_dead_targets()
	if possible_targets.is_empty() || possible_targets.size()==0:
		return
	if selected_target not in possible_targets && !possible_targets.is_empty():
		selected_target = possible_targets[0]
	if !is_instance_valid(selected_target):
		selected_target = null
	_determine_selected_target()
	if selected_target == null || !is_instance_valid(selected_target):
		return
	_apply_turn_limit(delta)

	if fire_rate_cooldown > 0:
		fire_rate_cooldown -= delta
	if (selected_target != null) && _can_fire_now() && (fire_rate_cooldown<=0):
		_shoot()
		fire_rate_cooldown = 1.0 / _get_effective_fire_rate()

func _apply_turn_limit(delta: float) -> void:
	if selected_target == null || !is_instance_valid(selected_target):
		return
	var aim_point: Vector2 = _get_aim_point()
	var desired_rotation: float = global_position.angle_to_point(aim_point)
	var angle_delta: float = wrapf(desired_rotation - rotation, -PI, PI)
	var turn_speed: float = maxf(float(_config.get("turn_speed", 5.0)), 0.0)
	var max_step: float = turn_speed * delta
	if abs(angle_delta) <= max_step:
		rotation = desired_rotation
	else:
		rotation += sign(angle_delta) * max_step

func _shoot():
	var bullet_config: Dictionary = _config["bullet_config"].duplicate(true)
	bullet_config["special"] = _config.get("special", {}).duplicate(true)
	bullet_config["pierce"] = int(_config.get("special", {}).get("pierce", 0))
	bullet_config["source_tower"] = self
	var weapon_kind: int = int(_config.get("special", {}).get("weapon", Enums.WeaponType.BULLET))
	if weapon_kind == Enums.WeaponType.BALL:
		bullet_config["guidance"] = Enums.GuidanceType.BALL
		if int(bullet_config.get("fuse", Enums.Fuse.TIMER)) != Enums.Fuse.TIMER_EXPLOSIVE:
			bullet_config["fuse"] = Enums.Fuse.TIMER
		bullet_config["fuse_value"] = float(bullet_config.get("fuse_value", 1.0))
	elif weapon_kind == Enums.WeaponType.BEAM:
		bullet_config["guidance"] = Enums.GuidanceType.SMART
		bullet_config["fuse"] = Enums.Fuse.IMPACT
	elif weapon_kind == Enums.WeaponType.GRAB:
		bullet_config["guidance"] = Enums.GuidanceType.SMART
		bullet_config["fuse"] = Enums.Fuse.IMPACT
	var temp_bullet = BASE_BULLET.instantiate()
	temp_bullet.set_config(bullet_config)
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


func _ready() -> void:
	add_to_group("TOWER")##so the game over screen can freeze towers
	_ensure_navigation_agent()

##drops enemies that died (queue_free) from the target list, they stick
##around for a frame after death and would otherwise crash targeting
func _prune_dead_targets()->void:
	for i in range(possible_targets.size()-1,-1,-1):
		var candidate = possible_targets[i]
		if !is_instance_valid(candidate) || candidate.is_queued_for_deletion():
			if selected_target == candidate:
				selected_target = null
			possible_targets.remove_at(i)

func _determine_selected_target()->void:
	if _config.get("special", {}).get("select_target", false) and is_instance_valid(selected_target) and selected_target in possible_targets:
		return
	if _config["targeting"] == Enums.TargetingType.CLOSEST:
		var closest = possible_targets[0]
		for i in possible_targets:
			if i.global_position.distance_to(global_position) < global_position.distance_to(closest.global_position):
				closest = i
		selected_target = closest


	elif _config["targeting"] == Enums.TargetingType.STRONGEST:
		var strongest = possible_targets[0]
		for i in possible_targets:
			if i.get_health() > strongest.get_health():
				strongest = i
		selected_target = strongest


	elif _config["targeting"] == Enums.TargetingType.FIRST \
			or _config["targeting"] == Enums.TargetingType.LAST:
		var selected: Node = possible_targets[0]
		var selected_distance: float = _get_distance_to_enemy_goal(selected)
		for candidate in possible_targets:
			var candidate_distance: float = _get_distance_to_enemy_goal(candidate)
			if _config["targeting"] == Enums.TargetingType.FIRST and candidate_distance < selected_distance:
				selected = candidate
				selected_distance = candidate_distance
			elif _config["targeting"] == Enums.TargetingType.LAST and candidate_distance > selected_distance:
				selected = candidate
				selected_distance = candidate_distance
		selected_target = selected

func _get_distance_to_enemy_goal(target: Node) -> float:
	if target.has_method("get_distance_to_goal"):
		return float(target.get_distance_to_goal())
	return INF
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
	
