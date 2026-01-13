extends StaticBody2D
const Enums = preload("res://Main/ENUMS.gd")

#this is a cursed way to do it but duplicate() doesnt carry over actual values.
func dupeThisTower() -> Object:
	var toDupe = duplicate()
	toDupe.setThisTowersValues(get_name(),targetingMethod,minRange,maxRange,fireRate,shopCost,BulletObject.dupeThisBullet(),$'Sprite'.texture)
	return toDupe
#because instatiate doesnt work on existing objects
func setThisTowersValues(setName,setTargetingMethod, setMinRange,setMaxRange,setFireRate,setShopCost,setBulletObject,setSprite) -> void:
		#for future things like buffs auras ect
		add_to_group("TOWERS")
		name = setName
		targetingMethod = setTargetingMethod
		fireRate = setFireRate
		shopCost = setShopCost
		BulletObject = setBulletObject
		add_child(BulletObject)
		BulletObject.process_mode = Node.PROCESS_MODE_DISABLED
		BulletObject.hide()
		minRange = setMinRange #range needs to be added
		maxRange = setMaxRange
		get_node('Sprite').texture = setSprite #meant to look like res://SourceTowers/BaseTower/Base_Tower.tscn::AtlasTexture_ugiwr



var bulletDamage :int
var fireRate :int
var shopCost:int 
var minRange:int
var maxRange :int
var targetingMethod
#hand this a preload("src")
var BulletObject

#in use
var fireRateCooldown = 0
var possibleTargets = [] #constantly changing arr of targets
var selectedTarget = null # for holding a target seperate from possibleTargets

func _process(delta: float) -> void:
	#IMPLEMENT GUIDANCE METHODS
	if !possibleTargets.is_empty():
		if targetingMethod == Enums.TargetingTypes.CLOSEST:
			selectedTarget = possibleTargets[0]
		#if targetingMethod == Enums.TargetingTypes.LAST
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
	var tempBullet = BulletObject.dupeThisBullet()
	$'BulletContainer'.add_child(tempBullet)
	tempBullet.setTarget(selectedTarget) 
	tempBullet.show()
	tempBullet.process_mode = Node.PROCESS_MODE_ALWAYS
	tempBullet.global_position = $BulletSpawnPoint.global_position

func _on_targeting_range_body_entered(body: Node2D) -> void:
	if body.is_in_group("ENEMY"):
		possibleTargets.append(body)
func _on_targeting_range_body_exited(body: Node2D) -> void:
	if body in possibleTargets:
		possibleTargets.remove_at(possibleTargets.find(body))
