#extends CharacterBody2D
##class_name BaseBullet
#const Enums = preload(
	#"res://Main/enums.gd"
#)
#static func instance_and_config(packed_base_bullet:PackedScene,config:Dictionary)->BaseBullet:
	#var temp = packed_base_bullet.instantiate()
#
	#
	#
#"""
#"bullet_texture":getAtlasAreaTexture(TESTING_ATLAS,22,10,64),
				#"speed":251,##in pixles per second
				#"guidance":Enums.GuidanceType.SMART,
				#"direct_damage":5,#to whatever it hits, usually its intended target
				#"fuse":Enums.Fuse.IMPACT """
#func configureate_this(config:Dictionary)->void:
	#assert(
		#(
		#config.has("speed")&&
		#config.has("guidance")&&
		#config.has("bullet_texture")
		#),
		#"BULLET NOT BEING CONFIGURED PROPERLY"
	#)
	#get_node('Sprite').texture = config["bullet_texture"]
	#muzzle_velocity = config["speed"]
	#guidance = config["guidance"]
	## WHAT ARE WE EVEN DOING HERE, WHY NOT JUST STORE THIS AS A LIVE DICT
	#if config.has("damage"):
		#damage_number = config["damage"]
	#if config.has("fuse"):
		#fuse_type = config["fuse"]
	#if config.has("fuse_value"):
		#fuse_value = config["fuse_value"]
	#if config.has("status_effect"):
		#status_effect_data = config["status_effect"]
	#if config.has("guidance"):
		#guidance = config["guidance"]
	#if config.has("aoe_radius"):
		#aoe_radius = config["aoe_radius"]
		#$ExplosionArea/CollisionShape2D.shape.radius = config["aoe_radius"]
#
	#
	#
#func _init() -> void:
	#add_to_group("BULLETS")
	#process_mode = Node.PROCESS_MODE_DISABLED
	#hide()
	#z_index -= 1
##the constructor for new bullet types
###@depricated
#func set_bullet_values_via_config_object(configObject:Array):
	#
	#muzzle_velocity = configObject[0]
	#guidance = configObject[1]
	#AOERadius = configObject[6]
	#
	#
	#damageNumber = configObject[2]
	#fuseType = configObject[3]
	#fuseValue = configObject[4]
	#if configObject[5]!=null:
		#statusEffectData = configObject[5]
	#get_node('Sprite').texture = configObject[7] 
 ##to have it appear below its parent
	#return self
#@export var muzzle_velocity :int = -1
#@export var damage_number :int = -1#maybe depricated fine for now
#@export var fuse_type:Enums.Fuse  = Enums.Fuse.IMPACT
#@export var fuse_value :float  = -1
#@export var status_effect_data:Dictionary = {}
#@export var guidance:Enums.GuidanceType = Enums.GuidanceType.SMART
#@export var aoe_radius:float  = -1 #ignored if set to 0; need future damge thing
#
#var can_move = true #for freezing teh bullet in place for the explosion effect
#var target
#var targetPositionFixed:Vector2 #for dumb weapons
#var target_direction :Vector2
#
#
		#
#func set_bullet_target(setTarget):
	##update the visual radius of the sprite of the bullet.
	#if guidance == Enums.GuidanceType.BALL:
		#$'EnemyDetectionArea/HitboxArea'.shape.radius = AOERadius
		#$Sprite.scale = Vector2(AOERadius/16,AOERadius/16)
		##only for use in rolling, exploding balls
		#$ExplosionArea/CollisionShape2D.shape.radius = AOERadius*3
		#
		#
	##mostly for getting a targets fixed position
	#if setTarget == null:
		#print("TARGET INVALID")
		#queue_free()
	#target = setTarget
	#targetPositionFixed = setTarget.global_position
	##print('TARGET POS IS ',setTarget.global_position," OUR POS IS ",global_position)
	#target_direction = global_position.direction_to(targetPositionFixed)*muzzleVelocity
	##this is to initally look at the target, updated to current target pos if guidance is smart
	##mainly for BALL and POINT bullets
	#look_at(targetPositionFixed)
	#
#func set_texture(newTex):
	#$'Sprite'.texture =newTex
	#
	#
#func _physics_process(_delta: float) -> void:
	#if !can_move:
		#return
	#if !is_instance_valid(target) && guidance == Enums.GuidanceType.SMART: #makes sure target exists
		#queue_free()
	#
	#if guidance == Enums.GuidanceType.SMART:
		#if is_instance_valid(target):
			#look_at(target.global_position)
			#velocity = global_position.direction_to(target.global_position)*muzzleVelocity
			#move_and_slide()
		#else:
			#queue_free()
	#elif guidance == Enums.GuidanceType.DUMB || guidance == Enums.GuidanceType.BALL:
		#
		#velocity = target_direction
		#move_and_slide()
		#
	##proximity fuses and whatnot
	#if fuseType == Enums.Fuse.IMPACT:
		#pass #covered by _on_body_entered
	#elif fuseType == Enums.Fuse.POINT:
		#if global_position.distance_to(targetPositionFixed)<6:
			#explode()
	#elif fuseType == Enums.Fuse.TIMER || fuseType == Enums.Fuse.TIMER_EXPLOSIVE:
		#await get_tree().create_timer(fuseValue).timeout
		#if fuseType == Enums.Fuse.TIMER_EXPLOSIVE:
			#
			#print("TIMED FUSE GO BOOOM")
			#explode()
		#queue_free()
		#pass
	#else:
		#print("FUZE TYPE NOT IMPLEMENTED")
			#
	#
	#
		#
	#
#
#
#
#
#
#func explode():
	#var targets = $ExplosionArea.get_overlapping_bodies()
	#var temp = []
	#$ExplosionEffect.scale = Vector2(AOERadius/32,AOERadius/32) #scaling the explosion effect to the proper size
	#
	##get all bodies and make sure their enemies
	#for i in targets:
		#if i.is_in_group("ENEMY"):
			#temp.append(i)
	#print("NUM OF TGTs IN EXP ARE ",temp.size())
	#for i in temp:
		#
		#if !statusEffectData.is_empty():
			#if statusEffectData.application == Enums.StatusApplication.AOE :
				#print("APPLYING STATUS VIA AOE TO ENEMY")
				#i.apply_status_effect(statusEffectData['effectType'],statusEffectData['strength'],statusEffectData['duration'])
		#print("APPLYING AOE DMG TO ENEMY")
		#i.takeDamage(damageNumber)
	#can_move=false
	#$ExplosionEffect.visible=true
	#await get_tree().create_timer(0.1).timeout
	#queue_free()
		#
	#
#
#
#
#
#
#
#func _on_enemy_detection_area_body_entered(body: Node2D) -> void:
	##for direct hits, and application of status effects 
	#if body.is_in_group("ENEMY") && fuseType==Enums.Fuse.IMPACT:
		#body.takeDamage(damageNumber)
		#if !statusEffectData.is_empty():
			#if statusEffectData["application"] == Enums.StatusApplication.DIRECT:
				#body.apply_status_effect(statusEffectData['effectType'],statusEffectData['strength'],statusEffectData['duration'])
		#queue_free()
	#elif body.is_in_group("ENEMY") && fuseType==Enums.Fuse.TIMER && guidance == Enums.GuidanceType.BALL:
		#body.takeDamage(damageNumber)
		##print("BALLING DAMAGE")
		#if !statusEffectData.is_empty():
			#if statusEffectData["application"] == Enums.StatusApplication.DIRECT:
				#body.apply_status_effect(statusEffectData['effectType'],statusEffectData['strength'],statusEffectData['duration'])
		##queue_free()
