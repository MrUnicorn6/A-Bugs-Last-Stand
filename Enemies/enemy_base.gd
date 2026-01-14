extends CharacterBody2D
const Enums = preload("res://Main/ENUMS.gd")
var speed=100
var defaultSpeed #for undoing the slowness effect
var health = 10
var statuses = []
var canMove = true

#in use
var statusCoolDown


func setEnemyValues(setName,setHealth,setSpeed,setIfCamo,setResistances):
	add_to_group("ENEMY")
	set_name(setName)
	health = setHealth
	speed = setSpeed
	defaultSpeed = setSpeed
	if setIfCamo:
		add_to_group("CAMO")
	#resistances still need to be done



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
	
func _process(delta: float) -> void:
	pass
	#apply the effects that this enemy has
	#statuses held in here are in array format [type,strength,duration]
	
	

func _physics_process(delta: float) -> void:
	if !canMove :
		return
	get_parent().set_progress(get_parent().get_progress()+speed*delta)
	
	#checks its progress along the board
	if get_parent().get_progress() <0.999:
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
			print("STATUS ",i[0], "removed, Statuses length is now ",statuses.size())
			statuses.erase(i)
