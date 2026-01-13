extends CharacterBody2D
const Enums = preload(
    "res://Main/ENUMS.gd"
)

func dupeThisBullet():
	var toDupe = duplicate()
	toDupe.setBulletValues(muzzleVelocity,guidance,damage,AOERadius,$'Sprite'.texture)
	return toDupe
#the constructor for new bullet types
func setBulletValues(setMuzzleVelocity,setGuidance,setDamage,setAOERadius,setSprite):
		#for future things like buffs auras ect
		#print("CREATING NEW BULLET TYPE")
		add_to_group("BULLETS")
		muzzleVelocity = setMuzzleVelocity
		guidance = setGuidance
		AOERadius = setAOERadius
		damage = setDamage
		get_node('Sprite').texture = setSprite #meant to look like res://SourceTowers/BaseTower/Base_Tower.tscn::AtlasTexture_ugiwr
var muzzleVelocity
var damage #maybe depricated fine for now
var guidance 
var AOERadius #ignored if set to 0; need future damge thing

var target
var targetPositionFixed #for dumb weapons

func _process(_delta: float) -> void:
	pass
		
func setTarget(setTarget):
	target = setTarget
	targetPositionFixed = target.global_position
	
	
func _physics_process(_delta: float) -> void:
	if guidance == Enums.GuidanceTypes.SMART:
		look_at(target.global_position)
		velocity = global_position.direction_to(target.global_position)*muzzleVelocity
		move_and_slide()
	elif guidance == Enums.GuidanceTypes.DUMB:
		look_at(targetPositionFixed)
		velocity = global_position.direction_to(targetPositionFixed)*muzzleVelocity
		move_and_slide()
	#proximity fuses and whatnot
	
	
		
	





#ignore this for now,
func explode():
	var targets = $ExplosionArea.get_overlapping_bodies()
	var temp = []
	#print("TARGETS SIZE",targets.size())
	
	#get all bodies and make sure their enemies
	for i in targets:
		#print(i)
		if i.is_in_group("ENEMY"):
			temp.append(i)
	#deal damage to the enemies
	for i in temp:
		#print("ENEMY HEALTH IS ",i.health,"DAMAGE IS ",damage)
		i.health-= damage
		
	$ExplosionEffect.visible=true
	await get_tree().create_timer(0.1).timeout
	queue_free()
		
	
	
	





func _on_enemy_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("ENEMY"):
		body.takeDamage(damage,'FIRE')
		queue_free()
	pass # Replace with function body.
