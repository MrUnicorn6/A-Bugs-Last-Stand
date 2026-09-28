extends Camera2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

@export var mapPanSpeed = 600



func _physics_process(delta: float) -> void:
	var direction = Input.get_vector('MoveMapLeft',"MoveMapRight","MoveMapUp","MoveMapDown")
	#print(direction)
	direction = direction*mapPanSpeed
	global_position += direction*delta
	#print("Camerapos is ",global_position)
# Called every frame. 'delta' is the elapsed time since the previous frame.
