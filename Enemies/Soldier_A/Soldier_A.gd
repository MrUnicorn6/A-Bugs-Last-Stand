extends CharacterBody2D

@export var speed=100
var health = 10

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("ENEMY")
	#print(get_groups())


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#every frame adds speed (1000) to the progress along the path 
	get_parent().set_progress(get_parent().get_progress()+speed*delta)
	
	#checks health
	if health <=0 :
		#print("GOOD KILL")
		
		queue_free()
