extends Panel
var money=500
var health=100
@onready var HealthLabel = $HealthNumber
@onready var MoneyLabel = $MoneyNumber

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#print("TESTING VALUES ")
	changeMoney(100)
	changeHealth(10)
	pass # Replace with function body.
func changeMoney(amount):
	money = money-amount
	updateLabels()
func changeHealth(amount):
	health = health-amount
	updateLabels()
func updateLabels():
	MoneyLabel.text = str(money)
	HealthLabel.text = str(health)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
