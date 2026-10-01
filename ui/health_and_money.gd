extends Panel
var money=200
var health=100
@onready var health_label = $HealthNumber
@onready var money_label = $MoneyNumber

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_labels()
	pass # Replace with function body.
func change_money(amount:int):
	money = money-amount
	update_labels()
func change_health(amount:int):
	health = health-amount
	update_labels()
func update_labels():
	money_label.text = str(money)
	health_label.text = str(health)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
