class_name HealthComponent
extends Node

signal has_died
#avisaque se recibio daño
signal received_damage

var health: float = 100.0
var COINS_DROPPED_DEFAULT: int = 25
var game_manager: GameManager
# Evita que varios golpes en el mismo frame provoquen muertes duplicadas
# (oro y drops repetidos)
var _is_dead: bool = false


func damage(attack: Attack) -> void:
	if _is_dead:
		return

	health -= attack.damage
	#se emite cuando se aplica daño a los enanos
	received_damage.emit()

	if health <= 0:
		_is_dead = true
		#Se biusca en el banco en el momento de muerte, no en _ready
		game_manager = get_tree().get_first_node_in_group("game_manager")
		var calculated_value = (COINS_DROPPED_DEFAULT + Store.save[Store.DATA.COINS_BONUS] * 5) * game_manager.upgrade_manager.get_coin_bonus()
		if is_instance_valid(game_manager):
			game_manager.add_gold(calculated_value)
		has_died.emit()
