extends Panel

##emitted exactly once, when health first reaches 0
signal game_over

var money=200
var health=100
var is_game_over=false
@onready var health_label = $HealthNumber
@onready var money_label = $MoneyNumber

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_labels()
	pass # Replace with function body.
##negative amount refunds money, positive amount spends it (old shop behavior)
func change_money(amount:int):
	money = money-amount
	money = maxi(money,0)
	update_labels()

##money paid to the player (enemy bounties, wave bonuses)
func earn(amount:int):
	money = money+amount
	update_labels()

##amount is damage taken, health is clamped at 0 and game_over emits once
func change_health(amount:int):
	if is_game_over:
		return
	health = maxi(health-amount,0)
	update_labels()
	if health == 0:
		is_game_over = true
		game_over.emit()
func update_labels():
	money_label.text = str(money)
	health_label.text = str(health)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
