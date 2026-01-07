extends Node2D

@onready var Path = preload("res://Maps/BaseMapPath.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_spawn_timer_timeout() -> void:
	var TempPath = Path.instantiate()
	
	add_child(TempPath)
