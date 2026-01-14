extends StaticBody2D
const Enums = preload("res://Main/ENUMS.gd")

#this is a cursed way to do it but duplicate() doesnt carry over actual values.
func dupeThisTower() -> Object:
	var toDupe = duplicate()
	toDupe.setThisTowersValues(get_name(),targetingMethod,canSeeCamo,minRange,
		maxRange,fireRate,shopCost,BulletObject.dupeThisBullet(),$'Sprite'.texture)
	return toDupe
#because instatiate doesnt work on existing objects
func setThisTowersValues(setName,setTargetingMethod:Enums.TargetingTypes,
		setCanSeeCamo:Enums.CanSeeCamo,
		setMinRange,setMaxRange,setFireRate,setShopCost,
		setBulletObject,setSprite) -> void:
			
		#for future things like buffs auras ect
		add_to_group("TOWERS")
		name = setName
		targetingMethod = setTargetingMethod
		canSeeCamo = setCanSeeCamo
		fireRate = setFireRate
		shopCost = setShopCost
		BulletObject = setBulletObject
		add_child(BulletObject)
		BulletObject.process_mode = Node.PROCESS_MODE_DISABLED
		BulletObject.hide()
		minRange = setMinRange #range needs to be added
		maxRange = setMaxRange
		$'TargetingRange/TargetingHitbox'.shape.radius = maxRange
		get_node('Sprite').texture = setSprite #meant to look like res://SourceTowers/BaseTower/Base_Tower.tscn::AtlasTexture_ugiwr



var bulletDamage :int
var fireRate :float
var canSeeCamo:Enums.CanSeeCamo
var shopCost:int 
var minRange:int
var maxRange :int
var targetingMethod:Enums.TargetingTypes
#hand this a preload("src")
var BulletObject

#in use
var fireRateCooldown = 0
var possibleTargets = [] #constantly changing arr of targets
var selectedTarget = null # for holding a target seperate from possibleTargets

func _process(delta: float) -> void:
	#IMPLEMENT GUIDANCE METHODS
	 #targets furthest along/first target by default


	if !possibleTargets.is_empty():
		
		#visual of looking at target
		if is_instance_valid(selectedTarget):
			self.look_at(selectedTarget.global_position)

	#print("SELECTED TARGET IS ",selectedTarget.get_name())
	if !possibleTargets.is_empty() && possibleTargets[0] != null:
		if targetingMethod == Enums.TargetingTypes.CLOSEST:
			selectedTarget = possibleTargets[0]
			var closest = possibleTargets[0]
			for i in possibleTargets:
				if i.global_position.distance_to(global_position) < global_position.distance_to(closest.global_position):
					closest = i
			selectedTarget = closest
			
			
		elif targetingMethod == Enums.TargetingTypes.STRONGEST:
			selectedTarget = possibleTargets[0]
			var Strongest = possibleTargets[0]
			for i in possibleTargets:
				if i.health > Strongest.health:
					Strongest = i
			selectedTarget = Strongest
			
			
			
	#visual of looking at target
	if is_instance_valid(selectedTarget):
		self.look_at(selectedTarget.global_position)
	#firerate
	if fireRateCooldown > 0:
		fireRateCooldown -= delta
	if (selectedTarget != null)&& (fireRateCooldown<=0):
		shoot()
		fireRateCooldown = 1.0 / fireRate

func shoot():
	#print("number of possible targets is ",possibleTargets.size())
	var tempBullet = BulletObject.dupeThisBullet()
	$'BulletContainer'.add_child(tempBullet)
	tempBullet.setTarget(selectedTarget) 
	tempBullet.show()
	tempBullet.process_mode = Node.PROCESS_MODE_ALWAYS
	tempBullet.global_position = $BulletSpawnPoint.global_position

func _on_targeting_range_body_entered(body: Node2D) -> void:
	if canSeeCamo == Enums.CanSeeCamo.CANSEECAMO:
		if body.is_in_group("ENEMY"):
			#print("I SEE A CAMO FUCKER")
			possibleTargets.append(body)
	elif canSeeCamo == Enums.CanSeeCamo.CANNOTSEECAMO:
		if body.is_in_group("ENEMY") && !body.is_in_group("CAMO"):
			#print("I DONT SEE A CAMO FUCKER")
			possibleTargets.append(body)
func _on_targeting_range_body_exited(body: Node2D) -> void:
	if body in possibleTargets:
		possibleTargets.remove_at(possibleTargets.find(body))
