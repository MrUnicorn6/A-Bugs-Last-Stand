extends CharacterBody2D
const Enums = preload("res://Main/ENUMS.gd")



@export var speed:int
@export var displayName:String
@export var health:int
@export var isCamo:bool= false
@export var resistances:Dictionary = {}



#in use
var statusCoolDown
var goalPosition:Vector2
var canMove = true#for stun effects
@export var defaultSpeed:int #for undoing the slowness effect
var statuses = []


func setEnemyValues(data:Dictionary) -> Object:
	if !data.has("name") || !data.has("health") || !data.has("speed") || !data.has("texture"):
		print("ERROR IN CREATING ENEMY TYPE")
		return
	
	displayName = data["name"]
	health = data["health"]
	speed = data["speed"]
	defaultSpeed = data["speed"]
	$'Sprite2D'.texture = data["texture"]
		
	#non required parameters for enemies
	if data.has("resistances"):
		pass
		#print("SETTING RESISTANCE")
	
	if data.has("camo"):
		if data["camo"]:
			isCamo = data["camo"]
			add_to_group("CAMO")
	

	return self
func update(setGoalPosition:Vector2):
	self.goalPosition = setGoalPosition
	add_to_group("ENEMY")
	if isCamo:
		add_to_group("CAMO")
	$NavigationAgent2D.target_position = goalPosition
	

func takeDamage(amount):##WIP
	health -= amount
	#print("TAKING SOME DADMAGE, my health is ",health," DAMAGE WAS ",amount," NAME IS ",get_name())
	if health <=0 :
		queue_free()
	pass
func applyStatusEffect(type,strength,duration):
	#print("HEY STATUS EFFECT OF ",type,' ',strength,' ',duration)
	var temp = [type,strength,float(duration)]
	if type == Enums.StatusEffectType.STUN:
		
		canMove=false
	if type == Enums.StatusEffectType.SLOW:
		speed = speed/strength
	statuses.append(temp)
	

	#apply the effects that this enemy has
	#statuses held in here are in array format [type,strength,duration]
	
	

func _physics_process(delta: float) -> void:
	#print("ATTEMPTING ENEMY PATHFINDING")
	#if !$'NavigationAgent2D'.is_target_reachable():
		#print("TARGET UNREACHABLE")
	'''
	if !canMove :
		return
	get_parent().set_progress(get_parent().get_progress()+speed*delta)
	'''
	if !$NavigationAgent2D.is_target_reached():
		var navDirection = to_local($'NavigationAgent2D'.get_next_path_position()).normalized()
		velocity = navDirection*speed*delta*30
		move_and_slide()
	else:
		print("YOU FUCKING DIE")
		get_node("/root/Main/UI/HealthAndMoney").changeHealth(health)
		queue_free()



func _on_timer_timeout() -> void:
	# Called every 0.1 seconds
	if statuses.is_empty():
		return
	
	for i in statuses:
		

		if i[0] == Enums.StatusEffectType.DOT:
			if step_decimals(i[2])==0:
				takeDamage(i[1])
		
	for i in statuses:#decreases time of every status
		i[2] -= 0.1
		
		if i[2]<= -0.1: #removes statuses that have duration<-0.1, its negative so 
			#that the effect can be removed/unapplied before being deleted
			
			#removes some effects when the status is deleted
			if i[0] == Enums.StatusEffectType.STUN:
				canMove = true
			if i[0] == Enums.StatusEffectType.SLOW:
				speed = defaultSpeed
			#print("STATUS ",i[0], "removed, Statuses length is now ",statuses.size())
			statuses.erase(i)
