extends CharacterBody2D

var targetCoords
var speed =200
var damage



# Called when the node enters the scene tree for the first time.
func _init() -> void:
	pass
func _ready() -> void:
	pass # Replace with function body.

func _process(_delta: float) -> void:
	pass# Called every frame. 'delta' is the elapsed time since the previous frame.
func SetTarget(target):
	targetCoords = target.global_position
func _physics_process(_delta: float) -> void:
	#every frame this bullet trys to reach its fixed target
	#essentially GOLIS unguided rockets
	#collision is disabled for these bullets
	
	#checks distance to target position to decide to explode:
	if global_position.distance_to(targetCoords)<5:
		explode()
		$ExplosionEffect.visible=true
		await get_tree().create_timer(0.1).timeout
		queue_free()
	else:
		velocity = global_position.direction_to(targetCoords)*speed
		look_at(targetCoords)
		move_and_slide()
		
	






func explode():
	var targets = $ExplosionArea.get_overlapping_bodies()
	var temp = []
	#print("TARGETS SIZE",targets.size())
	
	#get all bodies and make sure their enemies
	for i in targets:
		#print(i)
		if i.is_in_group("ENEMY"):
			temp.append(i)
	#deal damage to the enemies
	for i in temp:
		#print("ENEMY HEALTH IS ",i.health,"DAMAGE IS ",damage)
		i.health-= damage
		
	
	
	
