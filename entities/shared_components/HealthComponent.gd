class_name HealthComponent
extends Node

signal has_died
#avisaque se recibio daño
signal received_damage

var health: float = 100.0
var COINS_DROPPED_DEFAULT: int = 25
var game_manager: GameManager


func damage(attack: Attack) -> void:
	health -= attack.damage
	#se emite cuando se aplica daño a los enanos
	received_damage.emit()

	if health <= 0:
		#Se biusca en el banco en el momento de muerte, no en _ready
		game_manager = get_tree().get_first_node_in_group("game_manager")
		if is_instance_valid(game_manager):
			game_manager.money_manager.add_gold(COINS_DROPPED_DEFAULT)
		has_died.emit()
