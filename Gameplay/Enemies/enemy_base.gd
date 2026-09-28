extends CharacterBody2D
const Enums = preload("res://Main/ENUMS.gd")

@export var _config:Dictionary




#in use
var statusCoolDown
var goalPosition:Vector2
var canMove = true#for stun effects
@export var defaultSpeed:int #for undoing the slowness effect
var statuses = []

static func instantiate_and_config(packed:PackedScene,to_config:Dictionary)->Object:
	var temp = packed.instantiate()
	temp.set_config(to_config)
	return temp
func set_config(data:Dictionary):
	assert(data.has("name") || data.has("health") || data.has("speed") || data.has("texture"),"ERROR IN CREATING ENEMY TYPE")
	_config = data
	_config["default_speed"] = _config["speed"]
		
	#non required parameters for enemies
	if data.has("resistances"):
		print("SETTING RESISTANCE")
	
	if data.has("camo"):
		if data["camo"]:
			add_to_group("CAMO")
	

func update(setGoalPosition:Vector2):
	self.goalPosition = setGoalPosition
	add_to_group("ENEMY")
	if _config.has("camo"):
		if _config["camo"]:
			add_to_group("CAMO")
	$NavigationAgent2D.target_position = goalPosition
	

func take_damage(amount,_element:Enums.ElementalType=Enums.ElementalType.NORMAL):##WIP
	_config["health"] -= amount
	print("ELEMENTAL DAMAGE TYPES ARE NOT IMPLEMENTED FOR ENEMEIS")
	#print("TAKING SOME DADMAGE, my health is ",health," DAMAGE WAS ",amount," NAME IS ",get_name())
	if _config["health"] <=0 :
		queue_free()
	pass
func applyStatusEffect(type,strength,duration):
	#print("HEY STATUS EFFECT OF ",type,' ',strength,' ',duration)
	var temp = [type,strength,float(duration)]
	if type == Enums.StatusEffectType.STUN:
		
		canMove=false
	if type == Enums.StatusEffectType.SLOW:
		_config["speed"]  = _config["speed"]/strength
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
		velocity = navDirection*_config["speed"]*delta*30
		move_and_slide()
	else:
		print("YOU FUCKING DIE")
		get_node("/root/Main/UI/HealthAndMoney").changeHealth(_config["health"])
		queue_free()



func _on_timer_timeout() -> void:
	# Called every 0.1 seconds
	if statuses.is_empty():
		return
	for i in statuses:
		if i[0] == Enums.StatusEffectType.DOT:
			if step_decimals(i[2])==0:
				take_damage(i[1])
	for i in statuses:#decreases time of every status
		i[2] -= 0.1
		if i[2]<= -0.1: #removes statuses that have duration<-0.1, its negative so 
			#that the effect can be removed/unapplied before being deleted
			#removes some effects when the status is deleted
			if i[0] == Enums.StatusEffectType.STUN:
				canMove = true
			if i[0] == Enums.StatusEffectType.SLOW:
				print("warning, slow status effect is not removed properly, or doesnt work well")
				#this removes all speeds regardless 
				#of # or speeds, not sure if its implemented properly
				_config["speed"] = _config["default_speed"]
			statuses.erase(i)
