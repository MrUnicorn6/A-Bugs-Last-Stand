extends StaticBody2D

#config vars
var bulletDamage = 10
var fireRate = 0.5

#loading bullet object
var Bullet = preload("res://SourceTowers/BoomTower/Boom_Bullet.tscn")

#in use
var fireRateCooldown = 0
var pathName
var possibleTargets = [] #constantly changing arr of targets
var selectedTarget = null # for holding a target seperate from possibleTargets

func _init() -> void:
	#for future things like buffs auras ect
	add_to_group("TOWERS")

func _process(delta: float) -> void:
	#something something target filtering (strong, first, last, ect)
	#this will just pick a target for now
	#for that use possibleTarget[x].get_parent().get_progress() and compare
	#how far along they are
	if !possibleTargets.is_empty():
		selectedTarget = possibleTargets[0]
	
	#visual of looking at target
	if is_instance_valid(selectedTarget):
		self.look_at(selectedTarget.global_position)
	
	#firerate stuff
	if fireRateCooldown > 0:
		fireRateCooldown -= delta
		
	if (selectedTarget != null)&& (fireRateCooldown<=0):	
		shoot()
		
		fireRateCooldown = 1.0 / fireRate

func shoot():
	#print("BANG")
	#create new bullet
	var tempBullet = Bullet.instantiate()
	#the bullet will handle its own guidance
	tempBullet.target = selectedTarget
	tempBullet.damage = bulletDamage
	#add it to the bullet folder and move it to the firing point/barrel on the
	#tower
	get_node("BulletContainer").add_child(tempBullet)
	tempBullet.global_position = $BulletSpawnPoint.global_position
	

func _on_targeting_range_body_entered(body: Node2D) -> void:
	#checks for enemies in range, and if their in group 'enemy'
	
	if body.is_in_group("ENEMY"):
		#print("TARGET FOUND", body.name)
		possibleTargets.append(body)
		#print("TARGETS ARR LEN", possibleTargets.size())
		
		


func _on_targeting_range_body_exited(body: Node2D) -> void:
	#removes enemies that are out of range
	if body in possibleTargets:
		possibleTargets.remove_at(possibleTargets.find(body))
	pass # Replace with function body.
