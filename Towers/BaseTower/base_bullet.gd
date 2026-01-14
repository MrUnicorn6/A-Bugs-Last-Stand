extends CharacterBody2D
const Enums = preload(
    "res://Main/ENUMS.gd"
)

func dupeThisBullet():
	var toDupe = duplicate()
	toDupe.setBulletValues(muzzleVelocity,guidance,damageNumber,fuseType,fuseValue,statusEffectData,AOERadius,$'Sprite'.texture)
	return toDupe
#the constructor for new bullet types
func setBulletValues(setMuzzleVelocity,setGuidance:Enums.GuidanceTypes,
		setDamageNumber,setFuseType:Enums.Fuses,setFuseValue,setStatusEffectData,
		setAOERadius,setSprite):
	#for future things like buffs auras ect
	#print("CREATING NEW BULLET TYPE")
	add_to_group("BULLETS")
	muzzleVelocity = setMuzzleVelocity
	guidance = setGuidance
	$ExplosionArea/CollisionShape2D.shape.radius = setAOERadius
	AOERadius = setAOERadius
	damageNumber = setDamageNumber
	fuseType = setFuseType
	fuseValue = setFuseValue
	statusEffectData = setStatusEffectData
	get_node('Sprite').texture = setSprite #meant to look like res://SourceTowers/BaseTower/Base_Tower.tscn::AtlasTexture_ugiwr
var muzzleVelocity
var damageNumber #maybe depricated fine for now
var fuseType 
var fuseValue #for things like timer or proxy fuse radius
var statusEffectData
var guidance 
var AOERadius #ignored if set to 0; need future damge thing

var canMove = true #for freezing teh bullet in place for the explosion effect
var target
var targetPositionFixed #for dumb weapons


		
func setTarget(setTarget):
	target = setTarget
	targetPositionFixed = target.global_position
	
	
func _physics_process(_delta: float) -> void:
	if !canMove:
		return
	if !is_instance_valid(target): #makes sure target exists
		queue_free()
		
	if guidance == Enums.GuidanceTypes.SMART:
		if is_instance_valid(target):
			look_at(target.global_position)
			velocity = global_position.direction_to(target.global_position)*muzzleVelocity
			move_and_slide()
		else:
			queue_free()
	elif guidance == Enums.GuidanceTypes.DUMB:
		look_at(targetPositionFixed)
		velocity = global_position.direction_to(targetPositionFixed)*muzzleVelocity
		move_and_slide()
		
	#proximity fuses and whatnot
	if fuseType == Enums.Fuses.IMPACT:
		pass #covered by _on_body_entered
	elif fuseType == Enums.Fuses.TIMER:
		if global_position.distance_to(targetPositionFixed)<6:
			explode()
	else:
		print("FUZE TYPE NOT IMPLEMENTED")
			
	
	
		
	





#ignore this for now,
func explode():
	var targets = $ExplosionArea.get_overlapping_bodies()
	var temp = []
	$ExplosionEffect.scale = Vector2(AOERadius/32,AOERadius/32) #scaling the explosion effect to the proper size
	#print("TARGETS SIZE",targets.size())
	#get all bodies and make sure their enemies
	for i in targets:
		if i.is_in_group("ENEMY"):
			temp.append(i)
	for i in temp:
		if statusEffectData !=null:
			if statusEffectData.application == Enums.StatusApplication.AOE :
				i.applyStatusEffect(statusEffectData['effectType'],statusEffectData['strength'],statusEffectData['duration'])
		i.takeDamage(damageNumber)
	canMove=false
	$ExplosionEffect.visible=true
	await get_tree().create_timer(0.1).timeout
	queue_free()
		
	
	





func _on_enemy_detection_area_body_entered(body: Node2D) -> void:
	
	if body.is_in_group("ENEMY") && fuseType==Enums.Fuses.IMPACT:
		body.takeDamage(damageNumber)
		if statusEffectData !=null:
			if statusEffectData["application"] == Enums.StatusApplication.DIRECT:
				body.applyStatusEffect(statusEffectData['effectType'],statusEffectData['strength'],statusEffectData['duration'])
		queue_free()
