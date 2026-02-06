extends Node

var packedEnemies:Dictionary
var roundCounter = 0
const RoundOne = ["fast","3","strong","3","camo","1","fly",2]
var goalPosition:Vector2 #usually player base or camp


func doRound():
	if roundCounter ==0:
		print("startinground1")
		@warning_ignore("integer_division")
		for i in RoundOne.size()/2:
			#make sure enemy exists
			if !packedEnemies.has(RoundOne[i*2]):
				print("CLANKER ",RoundOne[i*2], " NOT FOUND")
			var spawnNumber = int(RoundOne[i*2+1])
			var nextSpawn = packedEnemies[RoundOne[i*2]]
			for x in range(0,spawnNumber):
				#print("spawn number is ",x)
				await $'SpawnTimer'.timeout
				spawnEnemyOnPath(nextSpawn)
			

func setEnemies(setPackedEnemies):
	packedEnemies = setPackedEnemies
	
func setGoal():
	goalPosition = $TemporaryTarget.global_position

	
	#spawn enemy every few secs
func spawnEnemyOnPath(enemie):
	var tempEnemie = enemie.instantiate()
	tempEnemie.update(goalPosition)
	tempEnemie.process_mode = Node.PROCESS_MODE_DISABLED
	$'EnemieContainer'.add_child(tempEnemie)
	tempEnemie.global_position = $'Spawn Node'.global_position
	#var tempPath = PathFollow2D.new()
	#$'EnemyPath'.add_child(tempPath)
	#tempPath.add_child(tempEnemie)
	#tempPath.progress_ratio = 0
	tempEnemie.process_mode = Node.PROCESS_MODE_ALWAYS
