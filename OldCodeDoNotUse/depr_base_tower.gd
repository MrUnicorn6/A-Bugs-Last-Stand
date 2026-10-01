#extends StaticBody2D
###an abstract class intended for later instancing and configuration 
###via a config dict, as specified by towers_config found in (at least for now)
###GameplayObjectsLoader.gd
##class_name Base_Tower
#
#
#func set_this_towers_values(setName,setTargetingMethod:Enums.TargetingType,
		#setCanSeeCamo:Enums.CanSeeCamo,
		#setMinRange,setMaxRange,setFireRate,setShopCost,
		#setPackedBulletObject,setSprite,setUpgrades) -> Object:
		#add_to_group("TOWERS")
		#display_name = setName
		#targetingMethod = setTargetingMethod
		#canSeeCamo = setCanSeeCamo
		#fireRate = setFireRate
		#packedBulletObject = setPackedBulletObject
		##$'BaseBullet'.hide()
		#minRange = setMinRange #range needs to be added
		#_maxRange = setMaxRange
		#shopCost = setShopCost
		#upgrade_count = 0
		#upgrades = setUpgrades #for upgrade info
		#$'TargetingRange/TargetingHitbox'.shape.radius = _maxRange
		##print("SETTING MAX RANGE TO ",setMaxRange, " on tower ",display_name," and shopcost ",shopCost)
		#get_node('Sprite').texture = setSprite 
		##meant to look like res://SourceTowers/BaseTower/Base_Tower.tscn::AtlasTexture_ugiwr
		#return self
#func _draw() -> void:
	#if displayRange:
		#draw_circle(Vector2(0,0),_maxRange,Color(0,0,0,0.25),true)
#@export var display_name :String
#@export var fireRate :float
#@export var canSeeCamo:Enums.CanSeeCamo
#@export var shopCost:int 
#@export var minRange:int
#@export var _maxRange :int
#@export var targetingMethod:Enums.TargetingType
#@export var packedBulletObject:PackedScene
##hand this a preload("src")
#
#
#@export var upgrades :Array
##this could be an issue, well see:
#
##in use
#var displayRange = false
#var upgrade_count = 0
#var fireRateCooldown = 0
#var possible_targets = [] #constantly changing arr of targets
#var selectedTarget = null # for holding a target seperate from possible_targets
#
#
	##firerate
#func _physics_process(delta: float) -> void:
	##print("Pys node on tower")
	#if !possible_targets.is_empty():
		##visual of looking at target
		#if is_instance_valid(selectedTarget):
			#self.look_at(selectedTarget.global_position)
	#
	#if !possible_targets.is_empty():
		#if possible_targets[0] == null:
			#possible_targets.remove_at(0)
			#return
		##print('in targets selection loop')
		#if targetingMethod == Enums.TargetingType.CLOSEST:
			#selectedTarget = possible_targets[0]
			#var closest = possible_targets[0]
			#for i in possible_targets:
				#if i.global_position.distance_to(global_position) < global_position.distance_to(closest.global_position):
					#closest = i
			#selectedTarget = closest
			#
			#
		#elif targetingMethod == Enums.TargetingType.STRONGEST:
			#selectedTarget = possible_targets[0]
			#var Strongest = possible_targets[0]
			#for i in possible_targets:
				#if i.health > Strongest.health:
					#Strongest = i
			#selectedTarget = Strongest
		#elif targetingMethod == Enums.TargetingType.FIRST:
			#selectedTarget = possible_targets[0]
		#elif targetingMethod == Enums.TargetingType.LAST:
			#selectedTarget = possible_targets[0]
			#var last_target = possible_targets[0]
			#for i in possible_targets:
				#if i.get_parent().progress < selectedTarget.get_parent().progress:
					#last_target = i
			#selectedTarget = last_target
	#
#func shoot():
	#print("BANG")
	#var tempBullet = packedBulletObject.instantiate()
	#$'BulletContainer'.add_child(tempBullet)
	#tempBullet.global_position = $BulletSpawnPoint.global_position
	#tempBullet.set_bullet_target(selectedTarget) 
	#tempBullet.process_mode = Node.PROCESS_MODE_ALWAYS
	#tempBullet.show()
#func _on_targeting_range_body_entered(body: Node2D) -> void:
	#print("target entered, ",body.get_groups())
	#if canSeeCamo == Enums.CanSeeCamo.CAN_SEE_CAMO:
		#if body.is_in_group("ENEMY"):
			##print("I SEE A CAMO FUCKER")
			#possible_targets.append(body)
	#elif canSeeCamo == Enums.CanSeeCamo.CANNOT_SEE_CAMO:
		#if body.is_in_group("ENEMY") && !body.is_in_group("CAMO"):
			#possible_targets.append(body)
#func _on_targeting_range_body_exited(body: Node2D) -> void:
	#if body in possible_targets:
		#possible_targets.remove_at(possible_targets.find(body))
	#if body == selectedTarget:
		#selectedTarget = null
#func update_possible_targets():
	#var bodies = $'TargetingRange'.get_overlapping_bodies()
	#for i in bodies:
		#if canSeeCamo == Enums.CanSeeCamo.CAN_SEE_CAMO:
			#if i.is_in_group("ENEMY"):
				#possible_targets.append(i)
		#elif canSeeCamo == Enums.CanSeeCamo.CANNOT_SEE_CAMO:
			#if i.is_in_group("ENEMY") && !i.is_in_group("CAMO"):
				#possible_targets.append(i)
	##print("done updating targets")
##to call the GUI to show upgrade options
#func _on_clicked_on_detector_gui_input(event: InputEvent) -> void:
	#
	#if event is InputEventMouseButton and event.button_mask==0:
		#get_node("/root/Main/UI").change_to_upgrade_screen(self,upgrades)
	#pass # Replace with function body.
#
#func upgrade_once(selectedSpecialTower = ""):
	#if upgrade_count==0:
		#execute_upgrade(1)
		#update_possible_targets()
		#print(display_name," UPGRADED TO LEVEL 1")
	#elif upgrade_count == 1:
		#execute_upgrade(2)
		#update_possible_targets()
		#print(display_name," UPGRADED TO LEVEL 2")
	#elif upgrade_count == 2:
		#print(display_name," UPGRADED TO LEVEL 3, PATH")
		#if selectedSpecialTower =="":
			#print("WARNING NO PATH WAS SELECTED BUT TOWER UPGRADE() CALLED ANYWAY")
		#print("PREFORMING UPGRADE TO PATH TOWER: ",selectedSpecialTower)
		#var futuretower = get_node("/root/Main").get_packed_special_tower(selectedSpecialTower).instantiate()
		#futuretower.global_position = global_position
		#$'../'.add_child(futuretower)
		#futuretower.show()
		#futuretower.process_mode = Node.ProcessMode.PROCESS_MODE_ALWAYS
		#futuretower.update_possible_targets()
		#futuretower.rotation_degrees -= 90
		#queue_free()
		#get_node("/root/Main/UI").change_to_upgrade_screen(futuretower,futuretower.upgrades)
#func execute_upgrade(tolevel):
	#var toUpgradeBullet = packedBulletObject.instantiate()
	#var i = upgrades[tolevel-1]#to grab the first upgrade, or level 1; towers start at level 0
		##the for loop is to get and apply each item in the object like {"range":10,"damage":5}
	#if i.has("range"):
		##print("NOT UPGRADING THE RANGE OF TOWER ",display_name)
		#_maxRange += i["range"]
		#$'TargetingRange/TargetingHitbox'.shape.radius = _maxRange
		##print(display_name," RANGE UPGRADED TO ",_maxRange)
	#if i.has("sprite"):
		#get_node('Sprite').texture = i['sprite'] 
	#if i.has("damage"):
		#toUpgradeBullet.damageNumber +=i["damage"]
	#if i.has("firerate"):
		#fireRate+= i["firerate"]
	#if i.has("canseecamo"):
		#canSeeCamo = i["canseecamo"]
	#if i.has("status"):
		#toUpgradeBullet.statusEffectData = i["status"]
	#if i.has("aoeradius"):
		#toUpgradeBullet.AOERadius += i["aoeradius"]
	#if i.has("fusevalue"):
		#toUpgradeBullet.fuseValue +=i["fusevalue"]
	#if i.has("muzzleVelocity"):
		#toUpgradeBullet.muzzleVelocity +=i["muzzleVelocity"]
	#
	##apply and repack the bullet for future use
	#var temp = PackedScene.new()
	#temp.pack(toUpgradeBullet)
	#packedBulletObject = temp
	#
	#upgrade_count+=1
