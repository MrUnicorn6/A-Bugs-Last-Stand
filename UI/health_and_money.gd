extends Panel
var Money=50
var Health=100
@onready var HealthLabel = $HealthNumber
@onready var MoneyLabel = $MoneyNumber

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	updateLabels()
	pass # Replace with function body.
func changeMoney(Amount:int):
	Money = Money-Amount
	updateLabels()
func changeHealth(Amount:int):
	Health = Health-Amount
	updateLabels()
func updateLabels():
	MoneyLabel.text = str(Money)
	HealthLabel.text = str(Health)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
