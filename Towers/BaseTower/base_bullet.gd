extends CharacterBody2D
const Enums = preload(
    "res://Main/ENUMS.gd"
)
#the constructor for new bullet types
func setBulletValuesViaConfigOBject(configObject:Array):
	add_to_group("BULLETS")
	muzzleVelocity = configObject[0]
	guidance = configObject[1]
	$ExplosionArea/CollisionShape2D.shape.radius = configObject[6]
	AOERadius = configObject[6]
	
	process_mode = Node.PROCESS_MODE_DISABLED
	hide()
	damageNumber = configObject[2]
	fuseType = configObject[3]
	fuseValue = configObject[4]
	if is_instance_valid(configObject[5]):
		statusEffectData = configObject[5]
	#print("bullet sprite is ",configObject[7])
	get_node('Sprite').texture = configObject[7] 
	z_index -= 1 #to have it appear below its parent
	return self
@export var muzzleVelocity :int
@export var damageNumber :int#maybe depricated fine for now
@export var fuseType:Enums.Fuses
@export var fuseValue :float
@export var statusEffectData:Dictionary 
@export var guidance:Enums.GuidanceTypes
@export var AOERadius:float #ignored if set to 0; need future damge thing

var canMove = true #for freezing teh bullet in place for the explosion effect
var target
var targetPositionFixed:Vector2 #for dumb weapons
var targetDirection :Vector2


		
func setBulletTarget(setTarget):
	#update the visual radius of the sprite of the bullet.
	if guidance == Enums.GuidanceTypes.BALL:
		$'EnemyDetectionArea/HitboxArea'.shape.radius = AOERadius
		$Sprite.scale = Vector2(AOERadius/16,AOERadius/16)
		#only for use in rolling, exploding balls
		$ExplosionArea/CollisionShape2D.shape.radius = AOERadius*3
		
		
	#mostly for getting a targets fixed position
	if setTarget == null:
		print("TARGET INVALID")
		queue_free()
	target = setTarget
	targetPositionFixed = setTarget.global_position
	#print('TARGET POS IS ',setTarget.global_position," OUR POS IS ",global_position)
	targetDirection = global_position.direction_to(targetPositionFixed)*muzzleVelocity
	#this is to initally look at the target, updated to current target pos if guidance is smart
	#mainly for BALL and POINT bullets
	look_at(targetPositionFixed)
	
func setTexture(newTex):
	$'Sprite'.texture =newTex
	
	
func _physics_process(_delta: float) -> void:
	if !canMove:
		return
	if !is_instance_valid(target) && guidance == Enums.GuidanceTypes.SMART: #makes sure target exists
		queue_free()
	
	if guidance == Enums.GuidanceTypes.SMART:
		if is_instance_valid(target):
			look_at(target.global_position)
			velocity = global_position.direction_to(target.global_position)*muzzleVelocity
			move_and_slide()
		else:
			queue_free()
	elif guidance == Enums.GuidanceTypes.DUMB || guidance == Enums.GuidanceTypes.BALL:
		
		velocity = targetDirection
		move_and_slide()
		
	#proximity fuses and whatnot
	if fuseType == Enums.Fuses.IMPACT:
		pass #covered by _on_body_entered
	elif fuseType == Enums.Fuses.POINT:
		if global_position.distance_to(targetPositionFixed)<6:
			explode()
	elif fuseType == Enums.Fuses.TIMER || fuseType == Enums.Fuses.TIMEREXPLOSIVE:
		await get_tree().create_timer(fuseValue).timeout
		if Enums.Fuses.TIMEREXPLOSIVE:
			
			print("TIMED FUSE GO BOOOM")
			explode()
		queue_free()
		pass
	else:
		print("FUZE TYPE NOT IMPLEMENTED")
			
	
	
		
	





func explode():
	var targets = $ExplosionArea.get_overlapping_bodies()
	var temp = []
	$ExplosionEffect.scale = Vector2(AOERadius/32,AOERadius/32) #scaling the explosion effect to the proper size
	
	#get all bodies and make sure their enemies
	for i in targets:
		if i.is_in_group("ENEMY"):
			temp.append(i)
	print("NUM OF TGTs IN EXP ARE ",temp.size())
	for i in temp:
		
		if !statusEffectData.is_empty():
			if statusEffectData.application == Enums.StatusApplication.AOE :
				print("APPLYING STATUS VIA AOE TO ENEMY")
				i.applyStatusEffect(statusEffectData['effectType'],statusEffectData['strength'],statusEffectData['duration'])
		print("APPLYING AOE DMG TO ENEMY")
		i.takeDamage(damageNumber)
	canMove=false
	$ExplosionEffect.visible=true
	await get_tree().create_timer(0.1).timeout
	queue_free()
		
	






func _on_enemy_detection_area_body_entered(body: Node2D) -> void:
	#for direct hits, and application of status effects 
	if body.is_in_group("ENEMY") && fuseType==Enums.Fuses.IMPACT:
		body.takeDamage(damageNumber)
		if !statusEffectData.is_empty():
			if statusEffectData["application"] == Enums.StatusApplication.DIRECT:
				body.applyStatusEffect(statusEffectData['effectType'],statusEffectData['strength'],statusEffectData['duration'])
		queue_free()
	elif body.is_in_group("ENEMY") && fuseType==Enums.Fuses.TIMER && guidance == Enums.GuidanceTypes.BALL:
		body.takeDamage(damageNumber)
		#print("BALLING DAMAGE")
		if !statusEffectData.is_empty():
			if statusEffectData["application"] == Enums.StatusApplication.DIRECT:
				body.applyStatusEffect(statusEffectData['effectType'],statusEffectData['strength'],statusEffectData['duration'])
		#queue_free()
