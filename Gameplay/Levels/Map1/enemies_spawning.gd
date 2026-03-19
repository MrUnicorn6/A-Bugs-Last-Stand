extends Node

const loader = preload("res://Gameplay/gameplay_objects_loader.gd")

var packed_enemies_config:Dictionary
var round_counter = 0
const round_one = ["fast","3","strong","3","camo","1","fly",2]
var goal_position:Vector2 #usually player base or camp


func doRound():
	if round_counter ==0:
		print("startinground1")
		@warning_ignore("integer_division")
		for i in round_one.size()/2:
			#make sure enemy exists
			if !packed_enemies_config.has(round_one[i*2]):
				print("CLANKER ",round_one[i*2], " NOT FOUND")
			var spawnNumber = int(round_one[i*2+1])
			var nextSpawn = packed_enemies_config[round_one[i*2]]
			for x in range(0,spawnNumber):
				#print("spawn number is ",x)
				await $'SpawnTimer'.timeout
				spawnEnemyOnPath(nextSpawn)
			

func setEnemies(given_config):
	packed_enemies_config = given_config
	
func setGoal():
	goal_position = $TemporaryTarget.global_position

	
	#spawn enemy every few secs
func spawnEnemyOnPath(enemy_config):
	var tempEnemie =loader.instance_enemy(enemy_config)
	tempEnemie.update(goal_position)
	tempEnemie.process_mode = Node.PROCESS_MODE_DISABLED
	$'EnemieContainer'.add_child(tempEnemie)
	tempEnemie.global_position = $'Spawn Node'.global_position
	#var tempPath = PathFollow2D.new()
	#$'EnemyPath'.add_child(tempPath)
	#tempPath.add_child(tempEnemie)
	#tempPath.progress_ratio = 0
	tempEnemie.process_mode = Node.PROCESS_MODE_ALWAYS
