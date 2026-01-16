extends Path2D


var BaseEnemy = preload("res://Enemies/EnemyBase.tscn")
var i = 0

func _on_spawn_timer_timeout() -> void:
	if i==0:
		var path_follow_2d = PathFollow2D.new()
		path_follow_2d.set_progress(0.0)
		#print("spawning fastah")
		var tempenemy = BaseEnemy.instantiate()
		tempenemy.setEnemyValues('Fastah',10,110,false,null)
		path_follow_2d.add_child(tempenemy)
		add_child(path_follow_2d)
		i=1
	elif i==1:
		var path_follow_2d = PathFollow2D.new()
		path_follow_2d.set_progress(0.0)
		#print("spawning strongah")
		var tempenemySTRONG = BaseEnemy.instantiate()
		tempenemySTRONG.setEnemyValues('Strongah',20,60,true,null)
		#tempenemySTRONG.name = "STRONGO"
		tempenemySTRONG.speed = 60
		path_follow_2d.add_child(tempenemySTRONG)
		add_child(path_follow_2d)
		
		i=0
	
	#spawn enemy every few secs
	
