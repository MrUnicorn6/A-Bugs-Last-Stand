extends CharacterBody2D

@export var speed=100
var health = 10
var statuses




# Called when the node enters the scene tree for the first time.

	
func _ready() -> void:
	add_to_group("ENEMY")
	#print(get_groups())

func takeDamage(amount, type):##WIP
	print("TAKING SOME DADMAGE")
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#every frame adds speed (1000) to the progress along the path 
	get_parent().set_progress(get_parent().get_progress()+speed*delta)
	
	#checks health
	if health <=0 :
		#print("GOOD KILL")
		
		queue_free()
	
	#checks its progress along the board
	if get_parent().progress <0.999:
		#print("YOU FUCKING DIE")
		get_node("/root/Main/UI/HealthAndMoney").changeHealth(health)
		queue_free()
