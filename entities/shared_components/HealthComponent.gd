class_name HealthComponent
extends Node

signal has_died
#avisaque se recibio daño
signal received_damage

var health: float = 100.0
var COINS_DROPPED_DEFAULT: int = 25
var bank_label: Bank


func damage(attack: Attack) -> void:
	health -= attack.damage
	print(health)
	#se emite cuando se aplica daño a los enanos
	received_damage.emit()

	if health <= 0:
		#Se biusca en el banco en el momento de muerte, no en _ready
		bank_label = get_tree().get_first_node_in_group("bank")
		if is_instance_valid(bank_label):
			bank_label.gold += COINS_DROPPED_DEFAULT
		has_died.emit()
