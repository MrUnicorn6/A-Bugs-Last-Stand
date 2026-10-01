extends Node

const Loader = preload("res://gameplay/gameplay_objects_loader.gd")

var packed_enemies_config:Dictionary
var round_counter = 0
const ROUND_ONE = ["fast","3","strong","3","camo","1","fly",2]
var goal_position:Vector2 #usually player base or camp


func do_round():
	if round_counter ==0:
		print("startinground1")
		@warning_ignore("integer_division")
		for i in ROUND_ONE.size()/2:
			#make sure enemy exists
			if !packed_enemies_config.has(ROUND_ONE[i*2]):
				print("CLANKER ",ROUND_ONE[i*2], " NOT FOUND")
			var spawn_number = int(ROUND_ONE[i*2+1])
			var next_spawn = packed_enemies_config[ROUND_ONE[i*2]]
			for x in range(0,spawn_number):
				#print("spawn number is ",x)
				await $'EnemiesSpawning/SpawnTimer'.timeout
				spawn_enemy_on_path(next_spawn)
			

func set_enemies(given_config):
	packed_enemies_config = given_config
	
func set_goal():
	goal_position = $'EnemiesSpawning/TemporaryTarget/CollisionShape2D'.global_position

	
	#spawn enemy every few secs
func spawn_enemy_on_path(enemy_config):
	var temp_enemy =Loader.instance_enemy(enemy_config)
	temp_enemy.update(goal_position)
	temp_enemy.process_mode = Node.PROCESS_MODE_DISABLED
	$'EnemiesSpawning/EnemyContainer'.add_child(temp_enemy)
	temp_enemy.global_position = $'EnemiesSpawning/SpawnNode'.global_position
	temp_enemy.process_mode = Node.PROCESS_MODE_ALWAYS
