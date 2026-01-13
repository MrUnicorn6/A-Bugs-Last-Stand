extends Path2D


var BaseEnemy = preload("res://Enemies/EnemyBase.tscn")


func _on_spawn_timer_timeout() -> void:
	var tempenemy = BaseEnemy.instantiate()
	var path_follow_2d = PathFollow2D.new()
	path_follow_2d.add_child(tempenemy)
	add_child(path_follow_2d)
	#spawn enemy every few secs
	
