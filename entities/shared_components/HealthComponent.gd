class_name HealthComponent
extends Node

signal has_died
#avisaque se recibio daño 
signal received_damage

var STARTING_HEALTH: float = 100.0
var COINS_DROPPED_DEFAULT: int = 25
var health: float
var coins_dropped: int

@onready var bank_label: Bank = get_tree().get_first_node_in_group("bank")


func _ready() -> void:
	health = STARTING_HEALTH
	coins_dropped = COINS_DROPPED_DEFAULT


func damage(attack: Attack) -> void:
	health -= attack.damage
	print(health)
	#se emite cuando se aplica daño a los enanos
	received_damage.emit()

	if health <= 0:
		#Se biusca en el banco en el momento de muerte, no en _ready 
		bank_label = get_tree().get_first_node_in_group("bank")
		if is_instance_valid(bank_label):
			bank_label.gold += coins_dropped
		has_died.emit()
