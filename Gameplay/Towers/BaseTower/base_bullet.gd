extends CharacterBody2D


class_name Bullet


const Enums = preload(
    "res://Main/ENUMS.gd"
)
var _config:Dictionary
#in use vars
var can_move = true #for freezing teh bullet in place for the explosion effect
var target:Node2D
var target_position_fixed:Vector2 #for dumb bullets
var target_direction_velocity:Vector2# for ball type bullets

"""
"bullet_texture":getAtlasAreaTexture(TestingAtlas,22,10,64),
				"speed":251,##in pixles per second
				"guidance":Enums.GuidanceTypes.SMART,
				"direct_damage":5,#to whatever it hits, usually its intended target
				"fuse":Enums.Fuses.IMPACT """


func set_config(new_config:Dictionary)->void:
	_config = new_config
	#like ball stuff
	if _config.has("aoe_radius"):
		$ExplosionArea/CollisionShape2D.shape.radius = _config["aoe_radius"]
	if _config["guidance"]==Enums.GuidanceTypes.BALL:
		$'EnemyDetectionArea/HitboxArea'.shape.radius = _config["aoe_radius"]
		$Sprite.scale = Vector2(_config["aoe_radius"]/16,_config["aoe_radius"]/16)
	if _config.has("bullet_texture"):
		get_node('Sprite').texture = _config["bullet_texture"]


##called once, and is fired at a specific target, or a specific position
func shoot_at_target(set_target:Node2D,intended_position:Vector2):
	#update the visual radius of the sprite of the bullet.
	print("BALL BULLET NOT WORKIGN YET")
		
	#checking for validity
	if set_target == null && intended_position==null:
		print("TARGET INVALID")
		queue_free()
	if set_target !=null:
		target = set_target
		target_position_fixed = set_target.global_position
		target_direction_velocity = global_position.direction_to(target_position_fixed)*_config["speed"]
		#this is to initally look at the target, updated to current target pos if 
		#guidance is smart
		#mainly for BALL and POINT bullets
		look_at(target_position_fixed)
	if set_target==null&&intended_position!=null:
		target_position_fixed = intended_position
		target_direction_velocity = global_position.direction_to(target_position_fixed)*_config["speed"]
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


func _physics_process(_delta: float) -> void:
	if !can_move:
		return
	if !is_instance_valid(target) && _config["guidance"] == Enums.GuidanceTypes.SMART: #makes sure target exists
		queue_free()
	if _config["guidance"] == Enums.GuidanceTypes.SMART:
		if is_instance_valid(target):
			look_at(target.global_position)
			velocity = global_position.direction_to(target.global_position)*_config["speed"]
			move_and_slide()
		else:
			queue_free()
	elif _config["guidance"] == Enums.GuidanceTypes.DUMB || _config["guidance"] == Enums.GuidanceTypes.BALL:
		
		velocity = target_direction_velocity
		move_and_slide()
		
	#proximity fuses and whatnot
	if _config["fuse"] == Enums.Fuses.IMPACT:
		pass #covered by _on_body_entered
	elif _config["fuse"] == Enums.Fuses.POINT:
		if global_position.distance_to(target_position_fixed)<6:
			explode()
	elif _config["fuse"] == Enums.Fuses.TIMER || _config["fuse"] == Enums.Fuses.TIMEREXPLOSIVE:
		await get_tree().create_timer(_config["fuse_value"]).timeout
		if _config["fuse"] == Enums.Fuses.TIMEREXPLOSIVE:
			
			#print("TIMED FUSE GO BOOOM")
			explode()
		queue_free()
	else:
		print("FUZE TYPE NOT IMPLEMENTED")

func explode():
	var targets = $ExplosionArea.get_overlapping_bodies()
	var temp = []
	$ExplosionEffect.scale = Vector2(_config["aoe_radius"]/32,_config["aoe_radius"]/32) #scaling the explosion effect to the proper size
	
	#get all bodies and make sure their enemies
	for i in targets:
		if i.is_in_group("ENEMY"):
			temp.append(i)
	#print("NUM OF TGTs IN EXP ARE ",temp.size())
	for i in temp:
		if _config.has("status_effect"):
			if _config["status_effect"]["status_application"].application == Enums.StatusApplication.AOE :
				print("NOT APPLYING STATUS VIA AOE TO ENEMY, AS ENEMY NEEDS TO BE UPDATED")

		#print("APPLYING AOE DMG TO ENEMY")
		i.take_damage(_config["aoe_damage"])
	can_move=false
	print("BOOOM")
	$ExplosionEffect.visible=true
	await get_tree().create_timer(0.15).timeout
	queue_free()




func _on_enemy_detection_area_body_entered(body: Node2D) -> void:
		#for direct hits, and application of status effects 
	if body.is_in_group("ENEMY") && _config["guidance"]==Enums.Fuses.IMPACT:
		body.take_damage(_config["damage"])
		#
		#if !statusEffectData.is_empty():
			#if statusEffectData["application"] == Enums.StatusApplication.DIRECT:
				#body.applyStatusEffect(statusEffectData['effectType'],statusEffectData['strength'],statusEffectData['duration'])
		queue_free()
	elif body.is_in_group("ENEMY") && _config["fuse"]==Enums.Fuses.TIMER && _config["guidance"] == Enums.GuidanceTypes.BALL:
		body.take_damage(_config["damage"])
		print("BALLING DAMAGE")
		#if !statusEffectData.is_empty():
			#if statusEffectData["application"] == Enums.StatusApplication.DIRECT:
				#body.applyStatusEffect(statusEffectData['effectType'],statusEffectData['strength'],statusEffectData['duration'])
		#queue_free()
