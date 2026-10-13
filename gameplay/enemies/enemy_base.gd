extends CharacterBody2D
const Enums = preload("res://main/enums.gd")

const LEAK_RADIUS = 40.0 ##how close to the goal counts as leaking through

@export var _config:Dictionary




#in use
var status_cooldown
var goal_position:Vector2
var can_move = true#for stun effects
var is_dead = false##stops double kills/leaks (bounty paid only once)
var dbg_timer = 0.0##TEMP DEBUG position logger
@export var default_speed:int #for undoing the slowness effect
var statuses = []

static func instantiate_and_config(packed:PackedScene,to_config:Dictionary)->Object:
	var temp = packed.instantiate()
	temp.set_config(to_config)
	return temp
func set_config(data:Dictionary):
	assert(data.has("name") || data.has("health") || data.has("speed") || data.has("texture"),"ERROR IN CREATING ENEMY TYPE")
	#duplicate so every enemy keeps its own health/speed, the shared
	#enemies_config dict would otherwise be mutated by every instance
	_config = data.duplicate()
	_config["default_speed"] = _config["speed"]
		
	#non required parameters for enemies
	if data.has("resistances"):
		print("SETTING RESISTANCE")
	
	if data.has("camo"):
		if data["camo"]:
			add_to_group("CAMO")
	

func update(new_goal_position:Vector2):
	self.goal_position = new_goal_position
	add_to_group("ENEMY")
	if _config.has("camo"):
		if _config["camo"]:
			add_to_group("CAMO")
	$NavigationAgent2D.target_position = goal_position
	

func take_damage(amount,_element:Enums.ElementalType=Enums.ElementalType.NORMAL):##WIP
	if is_dead:
		return##already dead, dont process/pay twice
	_config["health"] -= amount
	print("ELEMENTAL DAMAGE TYPES ARE NOT IMPLEMENTED FOR ENEMEIS")
	#print("TAKING SOME DADMAGE, my health is ",health," DAMAGE WAS ",amount," NAME IS ",get_name())
	if _config["health"] <=0 :
		is_dead = true
		_pay_bounty()
		queue_free()
	pass

##current health of this enemy, used by towers for STRONGEST targeting
func get_health()->int:
	return int(_config.get("health",0))

func get_distance_to_goal() -> float:
	return global_position.distance_to(goal_position)

##pays this enemies bounty to the player when it dies
func _pay_bounty():
	var health_and_money = _get_health_and_money()
	if health_and_money == null:
		return
	health_and_money.earn(int(_config.get("bounty",0)))

##the node holding the players health/money, may not exist yet during startup
##NOTE: its UI/SidePanel/HealthAndMoney, the old hardcoded path was missing SidePanel
func _get_health_and_money()->Node:
	return get_node_or_null("/root/Main/UI/SidePanel/HealthAndMoney")
func apply_status_effect(type: int, strength: float, duration: float) -> void:
	statuses.append([type, strength, maxf(duration, 0.0), 0.0])
	_refresh_status_effects()

func _refresh_status_effects() -> void:
	var is_stunned: bool = false
	var slow_multiplier: float = 1.0
	for status in statuses:
		if int(status[0]) == Enums.StatusEffectType.STUN:
			is_stunned = true
		elif int(status[0]) == Enums.StatusEffectType.SLOW:
			slow_multiplier *= maxf(float(status[1]), 1.0)
	can_move = !is_stunned
	if !_config.is_empty():
		_config["speed"] = float(_config.get("default_speed", _config.get("speed", 0.0))) / slow_multiplier

##to get an enemies current velocity for the perpose of calculating leading for bullets.
##
##respects stun effect
func get_current_velocity() ->Vector2:
	if !can_move:
		return Vector2.ZERO
	return velocity

	

func _physics_process(delta: float) -> void:
	#print("ATTEMPTING ENEMY PATHFINDING")
	#if !$'NavigationAgent2D'.is_target_reachable():
		#print("TARGET UNREACHABLE")
	#TEMP DEBUG
	dbg_timer += delta
	if dbg_timer >= 3.0:
		dbg_timer = 0
	#leak when the agent says reached OR when physically close to the goal:
	#the agent flag alone never fired on its own (it stalls short of the final waypoint)
	if !$NavigationAgent2D.is_target_reached() && global_position.distance_to(goal_position) > LEAK_RADIUS:
		var nav_direction = to_local($'NavigationAgent2D'.get_next_path_position()).normalized()
		if !can_move:
			velocity = Vector2.ZERO
		else:
			velocity = nav_direction*_config["speed"]*delta*30
		move_and_slide()
	else:
		#target is reached, the enemy leaks through the defense and deals
		#its leak damage to the player (NOT its remaining health)
		is_dead = true##no bounty for reaching the goal
		var health_and_money = _get_health_and_money()
		if health_and_money != null:
			health_and_money.change_health(int(_config.get("leak_damage",1)))
			print("YOU FUCKING DIE, health left ", health_and_money.health)
		else:
			print("YOU FUCKING DIE, NO HEALTH NODE")
		queue_free()



func _on_timer_timeout() -> void:
	for status_index in range(statuses.size() - 1, -1, -1):
		var status: Array = statuses[status_index]
		if int(status[0]) == Enums.StatusEffectType.DOT:
			status[3] = float(status[3]) + 0.1
			if float(status[3]) >= 0.9999:
				status[3] = maxf(float(status[3]) - 1.0, 0.0)
				take_damage(status[1])
				if is_dead:
					return
		status[2] = float(status[2]) - 0.1
		if float(status[2]) <= 0.0:
			statuses.remove_at(status_index)
	_refresh_status_effects()
