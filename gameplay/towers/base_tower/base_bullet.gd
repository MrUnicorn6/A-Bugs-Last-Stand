extends CharacterBody2D


class_name BaseBullet


const Enums = preload(
    "res://main/enums.gd"
)
var _config:Dictionary
var source_tower: Node = null
var pierce_remaining: int = 0
var life_timer: float = 3.0
var fuse_timer: float = 0.0
var has_exploded: bool = false
#in use vars
var can_move = true ##for freezing teh bullet in place for the explosion effect
var target:Node2D
var target_position_fixed:Vector2##for dumb bullets
var target_direction_velocity:Vector2## for ball type bullets

"""
"bullet_texture":getAtlasAreaTexture(TESTING_ATLAS,22,10,64),
				"speed":251,##in pixles per second
				"guidance":Enums.GuidanceType.SMART,
				"direct_damage":5,#to whatever it hits, usually its intended target
				"fuse":Enums.Fuse.IMPACT """


func set_config(new_config:Dictionary)->void:
	_config = new_config
	source_tower = _config.get("source_tower", null)
	pierce_remaining = int(_config.get("pierce", 0))
	life_timer = maxf(float(_config.get("lifetime", 3.0)), 0.0)
	fuse_timer = maxf(float(_config.get("fuse_value", 0.0)), 0.0)
	has_exploded = false
	#like ball stuff
	if _config.has("aoe_radius"):
		$ExplosionArea/CollisionShape2D.shape.radius = _config["aoe_radius"]
	if _config["guidance"]==Enums.GuidanceType.BALL:
		$'EnemyDetectionArea/HitboxArea'.shape.radius = _config["aoe_radius"]
		$Sprite.scale = Vector2(_config["aoe_radius"]/16,_config["aoe_radius"]/16)
	if _config.has("bullet_texture"):
		get_node('Sprite').texture = _config["bullet_texture"]


##called once, and is fired at a specific target, or a specific position
func shoot_at_target(set_target:Node2D,intended_position:Vector2):
	#update the visual radius of the sprite of the bullet.
		
	#checking for validity
	if set_target == null && intended_position==null:
		print("TARGET INVALID")
		queue_free()
	if set_target !=null:
		target = set_target
		target_position_fixed = set_target.global_position
		
		if _config["guidance"] == Enums.GuidanceType.LEAD:
			var lead_velocity := Vector2.ZERO
			if set_target.has_method("get_current_velocity"):
				lead_velocity = set_target.get_current_velocity()
			elif set_target is CharacterBody2D:
				lead_velocity = (set_target as CharacterBody2D).velocity
			target_position_fixed = BaseTower.solve_intercept(
				global_position,
				set_target.global_position,
				lead_velocity,
				_config["speed"]
			)
		
		 
		target_direction_velocity = global_position.direction_to(target_position_fixed)*_config["speed"]
	if set_target==null&&intended_position!=null:
		target_position_fixed = intended_position
		target_direction_velocity = global_position.direction_to(target_position_fixed)*_config["speed"]
	
	#inaccuracy: 0 = perfect aim, 1 = up to +-90 degrees off intended aim.
	#uniform roll, applied after guidance so LEAD still predicts truly then executes sloppily.
	#barrel (_get_aim_point) intentionally keeps aiming at the true point: barrel shows intent, bullet shows execution.
	var inaccuracy := clampf(float(_config.get("inaccuracy", 0.0)), 0.0, 1.0)
	if inaccuracy > 0.0 and target_direction_velocity.length() > 0.001:
		var max_error := inaccuracy * PI / 2.0
		var aim_error := randf_range(-max_error, max_error)
		var flight_distance := global_position.distance_to(target_position_fixed)
		target_direction_velocity = target_direction_velocity.rotated(aim_error)
		#keep POINT fuse + look_at consistent with where the bullet actually flies
		if flight_distance > 0.001:
			target_position_fixed = global_position + target_direction_velocity.normalized() * flight_distance
	
	look_at(target_position_fixed)
	process_mode = Node.PROCESS_MODE_INHERIT
	show()


func _init() -> void:
	add_to_group("BULLETS")
	process_mode = Node.PROCESS_MODE_DISABLED
	hide()
	z_index -= 1


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _physics_process(delta: float) -> void:
	if life_timer > 0.0:
		life_timer -= delta
	if life_timer <= 0.0:
		queue_free()
		return
	var guidance_type = _config["guidance"]
	if !can_move:
		return
	if guidance_type == Enums.GuidanceType.SMART:
		if is_instance_valid(target):
			look_at(target.global_position)
			velocity = global_position.direction_to(target.global_position)*_config["speed"]
			move_and_slide()
		elif target_direction_velocity.length() > 0.001:
			velocity = target_direction_velocity
			move_and_slide()
		else:
			queue_free()
	elif guidance_type == Enums.GuidanceType.DUMB || guidance_type == Enums.GuidanceType.BALL||guidance_type == Enums.GuidanceType.LEAD:
		
		velocity = target_direction_velocity
		move_and_slide()
		
	var fuse: int = int(_config.get("fuse", Enums.Fuse.IMPACT))
	if fuse == Enums.Fuse.POINT:
		if global_position.distance_to(target_position_fixed)<6:
			explode()
	elif fuse == Enums.Fuse.TIMER || fuse == Enums.Fuse.TIMER_EXPLOSIVE:
		fuse_timer -= delta
		if fuse_timer <= 0.0:
			if fuse == Enums.Fuse.TIMER_EXPLOSIVE:
				explode()
			else:
				queue_free()

func explode():
	if has_exploded:
		return
	has_exploded = true
	can_move = false
	var targets = $ExplosionArea.get_overlapping_bodies()
	var temp = []
	var aoe_radius: float = float(_config.get("aoe_radius", 0.0))
	$ExplosionEffect.scale = Vector2(aoe_radius/32.0, aoe_radius/32.0)
	
	#get all bodies and make sure their enemies
	for i in targets:
		if i.is_in_group("ENEMY"):
			temp.append(i)
	for i in temp:
		_apply_status_effects(i, Enums.StatusApplication.AOE)
		var aoe_damage: int = int(_config.get("aoe_damage", 0))
		if aoe_damage > 0:
			i.take_damage(aoe_damage)
	print("BOOOM")
	$ExplosionEffect.visible=true
	await get_tree().create_timer(0.15).timeout
	queue_free()

func _apply_status_effects(body: Node, application: int) -> void:
	if !body.has_method("apply_status_effect"):
		return
	var effects: Array = []
	var multiple_effects: Variant = _config.get("status_effects", [])
	if multiple_effects is Array:
		effects.append_array(multiple_effects)
	var single_effect: Variant = _config.get("status_effect", {})
	if single_effect is Dictionary:
		effects.append(single_effect)
	for status in effects:
		if int(status.get("status_application", Enums.StatusApplication.NONE)) != application:
			continue
		body.apply_status_effect(
			status.get("status_type", Enums.StatusEffectType.STUN),
			status.get("status_strength", 1.0),
			status.get("status_duration", 0.0)
		)

func _on_explosion_area_body_entered(body: Node2D) -> void:
	if int(_config.get("fuse", Enums.Fuse.IMPACT)) == Enums.Fuse.PROXIMITY and body.is_in_group("ENEMY"):
		explode()




func _on_enemy_detection_area_body_entered(body: Node2D) -> void:
	#print("SMACK ON ",body.get_groups()," ALSO GUIDANCE IS ",_config["fuse"]==Enums.Fuse.IMPACT)
		#for direct hits, and application of status effects 
	if body.is_in_group("ENEMY") && _config["fuse"]==Enums.Fuse.IMPACT:
		#print("SMACK IMPACT HIT")
		body.take_damage(_config["direct_damage"])
		if source_tower != null and source_tower.has_method("get_money_bonus"):
			var money_bonus: int = int(source_tower.get_money_bonus())
			if money_bonus > 0:
				var health_and_money = get_node_or_null("/root/Main/UI/SidePanel/HealthAndMoney")
				if health_and_money != null:
					health_and_money.earn(money_bonus)
		_apply_status_effects(body, Enums.StatusApplication.DIRECT)
		if pierce_remaining > 0:
			pierce_remaining -= 1
			if pierce_remaining > 0:
				return
		queue_free()
	elif body.is_in_group("ENEMY") \
			&& (_config["fuse"] == Enums.Fuse.TIMER || _config["fuse"] == Enums.Fuse.TIMER_EXPLOSIVE) \
			&& _config["guidance"] == Enums.GuidanceType.BALL:
		body.take_damage(_config["direct_damage"])
		print("BALLING DAMAGE")
		_apply_status_effects(body, Enums.StatusApplication.DIRECT)
				
