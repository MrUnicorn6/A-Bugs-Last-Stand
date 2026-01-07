extends CharacterBody2D

var target
var speed =500
var damage



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _process(_delta: float) -> void:
	if target==null:
		print("WARNING BULLET HAS NO TARGET, DELETING")
		queue_free()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	#every frame this bullet trys to reach its target
	if is_instance_valid(target):
		velocity = global_position.direction_to(target.global_position)*speed
		look_at(target.global_position)
		move_and_slide()
	else:
		print("WARNING BULLET HAS NO TARGET, DELETING")
		queue_free()


func _on_proximity_box_body_entered(body: Node2D) -> void:
	
	if body.is_in_group("ENEMY"):
		#print("good hit")
		body.health -=damage
		queue_free()
	pass # Replace with function body.
