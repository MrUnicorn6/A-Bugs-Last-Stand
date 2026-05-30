extends StaticBody2D
const Enums = preload("res://Main/ENUMS.gd")

func setThisTowersValues(setName,setTargetingMethod:Enums.TargetingTypes,
		setCanSeeCamo:Enums.CanSeeCamo,
		setMinRange,setMaxRange,setFireRate,setShopCost,
		setPackedBulletObject,setSprite,setUpgrades) -> Object:
		
		add_to_group("TOWERS")
		
		displayName = setName
		targetingMethod = setTargetingMethod
		canSeeCamo = setCanSeeCamo
		fireRate = setFireRate
		packedBulletObject = setPackedBulletObject
		#$'BaseBullet'.hide()
		minRange = setMinRange #range needs to be added
		_maxRange = setMaxRange
		shopCost = setShopCost
		upgradeCount = 0
		upgrades = setUpgrades #for upgrade info
		$'TargetingRange/TargetingHitbox'.shape.radius = _maxRange
		#print("SETTING MAX RANGE TO ",setMaxRange, " on tower ",displayName," and shopcost ",shopCost)
		get_node('Sprite').texture = setSprite 
		#meant to look like res://SourceTowers/BaseTower/Base_Tower.tscn::AtlasTexture_ugiwr
		return self
func _draw() -> void:
	if displayRange:
		draw_circle(Vector2(0,0),_maxRange,Color(0,0,0,0.25),true)

@export var displayName :String
@export var fireRate :float
@export var canSeeCamo:Enums.CanSeeCamo
@export var shopCost:int 
@export var minRange:int
@export var _maxRange :int
@export var targetingMethod:Enums.TargetingTypes
@export var packedBulletObject:PackedScene
#hand this a preload("src")


@export var upgrades :Array
#this could be an issue, well see:

#in use
var displayRange = false
var upgradeCount = 0
var fireRateCooldown = 0
var possibleTargets = [] #constantly changing arr of targets
var selectedTarget = null # for holding a target seperate from possibleTargets


	#firerate
func _physics_process(delta: float) -> void:
	if !possibleTargets.is_empty():
		#visual of looking at target
		if is_instance_valid(selectedTarget):
			self.look_at(selectedTarget.global_position)
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
		elif targetingMethod == Enums.TargetingTypes.FIRST:
			selectedTarget = possibleTargets[0]
		elif targetingMethod == Enums.TargetingTypes.LAST:
			selectedTarget = possibleTargets[0]
			var Last = possibleTargets[0]
			for i in possibleTargets:
				if i.get_parent().progress < selectedTarget.get_parent().progress:
					Last = i
			selectedTarget = Last
	if fireRateCooldown > 0:
		fireRateCooldown -= delta
	if (selectedTarget != null)&& (fireRateCooldown<=0):
		shoot()
		fireRateCooldown = 1.0 / fireRate

func shoot():
	#print("number of possible targets is ",possibleTargets.size())
	var tempBullet = packedBulletObject.instantiate()
	$'BulletContainer'.add_child(tempBullet)
	tempBullet.global_position = $BulletSpawnPoint.global_position
	tempBullet.setBulletTarget(selectedTarget) 
	tempBullet.process_mode = Node.PROCESS_MODE_ALWAYS
	tempBullet.show()
func _on_targeting_range_body_entered(body: Node2D) -> void:
	#print("target entered, ",body.get_groups())
	if canSeeCamo == Enums.CanSeeCamo.CANSEECAMO:
		if body.is_in_group("ENEMY"):
			#print("I SEE A CAMO FUCKER")
			possibleTargets.append(body)
	elif canSeeCamo == Enums.CanSeeCamo.CANNOTSEECAMO:
		if body.is_in_group("ENEMY") && !body.is_in_group("CAMO"):
			possibleTargets.append(body)
func _on_targeting_range_body_exited(body: Node2D) -> void:
	if body in possibleTargets:
		possibleTargets.remove_at(possibleTargets.find(body))
	if body == selectedTarget:
		selectedTarget = null



#to call the GUI to show upgrade options
func _on_clicked_on_detector_gui_input(event: InputEvent) -> void:
	
	if event is InputEventMouseButton and event.button_mask==0:
		get_node("/root/Main/UI").changeToUpgradeScreen(self,upgrades)
	pass # Replace with function body.

func upgradeOnce(selectedSpecialTower = ""):
	if upgradeCount==0:
		executeUpgrade(1)
		print(displayName," UPGRADED TO LEVEL 1")
	elif upgradeCount == 1:
		executeUpgrade(2)
		print(displayName," UPGRADED TO LEVEL 2")
	elif upgradeCount == 2:
		print(displayName," UPGRADED TO LEVEL 3, PATH")
		if selectedSpecialTower =="":
			print("WARNING NO PATH WAS SELECTED BUT TOWER UPGRADE() CALLED ANYWAY")
		print("PREFORMING UPGRADE TO PATH TOWER: ",selectedSpecialTower)
		var futuretower = get_node("/root/Main").getPackedSpecialTower(selectedSpecialTower).instantiate()
		futuretower.global_position = global_position
		$'../'.add_child(futuretower)
		futuretower.show()
		futuretower.process_mode = Node.ProcessMode.PROCESS_MODE_ALWAYS
		queue_free()
		get_node("/root/Main/UI").changeToUpgradeScreen(futuretower,futuretower.upgrades)
	
		
		
func executeUpgrade(tolevel):
	var toUpgradeBullet = packedBulletObject.instantiate()
	var i = upgrades[tolevel-1]#to grab the first upgrade, or level 1; towers start at level 0
		#the for loop is to get and apply each item in the object like {"range":10,"damage":5}
	if i.has("range"):
		#print("NOT UPGRADING THE RANGE OF TOWER ",displayName)
		_maxRange += i["range"]
		$'TargetingRange/TargetingHitbox'.shape.radius = _maxRange
		#print(displayName," RANGE UPGRADED TO ",_maxRange)
	if i.has("sprite"):
		get_node('Sprite').texture = i['sprite'] 
	if i.has("damage"):
		toUpgradeBullet.damageNumber +=i["damage"]
	if i.has("firerate"):
		fireRate+= i["firerate"]
	if i.has("canseecamo"):
		canSeeCamo = i["canseecamo"]
	if i.has("status"):
		toUpgradeBullet.statusEffectData = i["status"]
	if i.has("aoeradius"):
		toUpgradeBullet.AOERadius += i["aoeradius"]
	if i.has("fusevalue"):
		toUpgradeBullet.fuseValue +=i["fusevalue"]
	
	#apply and repack the bullet for future use
	var temp = PackedScene.new()
	temp.pack(toUpgradeBullet)
	packedBulletObject = temp
	
	upgradeCount+=1
