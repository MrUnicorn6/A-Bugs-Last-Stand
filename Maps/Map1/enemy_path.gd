extends Path2D


var BaseEnemy = preload("res://Enemies/EnemyBase.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_spawn_timer_timeout() -> void:
	var tempenemy = BaseEnemy.instantiate()
	var path_follow_2d = PathFollow2D.new()
	path_follow_2d.add_child(tempenemy)
	add_child(path_follow_2d)
	#spawn enemy every few secs
	
