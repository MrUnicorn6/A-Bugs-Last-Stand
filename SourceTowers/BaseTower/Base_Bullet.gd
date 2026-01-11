extends CharacterBody2D
const TargetingEnums = preload(
    "res://SourceTowers/BaseTower/TowerResources/TargetingAndGuidanceMethods.gd"
)

#the constructor for new bullet types
static func createNewBulletType(BaseClass,setMuzzleVelocity,setGuidance, setDamage,setSprite) -> Object:
		#for future things like buffs auras ect
		print("CREATING NEW BULLET TYPE")
		BaseClass.add_to_group("BULLETS")
		BaseClass.muzzleVelocity = setMuzzleVelocity
		BaseClass.guidance = setGuidance
		BaseClass.damage = setDamage
		BaseClass.get_node('Sprite').texture = setSprite #meant to look like res://SourceTowers/BaseTower/Base_Tower.tscn::AtlasTexture_ugiwr
		return BaseClass
var muzzleVelocity
var damage #maybe depricated fine for now
var guidance = TargetingEnums.TowerGuideOrTargetingEnums.GuidanceTypes.DUMB #meant to be an enum from Targeting and Guidance

var target
var targetPosition #for dumb weapons


#NOT FOR SHOOTING, ONLY FOR CREATING DIFGERENT BULLET TYPES
#func _init(setMuzzleVelocity,setDamage,setGuidance,setSpecialDamageEffects) -> void:
#	muzzleVelocity = setMuzzleVelocity
#	damage = setDamage
#	guidance = setGuidance
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _process(_delta: float) -> void:
	pass# Called every frame. 'delta' is the elapsed time since the previous frame.

func _physics_process(_delta: float) -> void:
	pass
	
	
		
	






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
		
	$ExplosionEffect.visible=true
	await get_tree().create_timer(0.1).timeout
	queue_free()
		
	
	
	
