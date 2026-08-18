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
		game_manager = Services.game_manager
		# El oro se calcula dentro del guard: la fórmula consulta el gestor y
		# antes se leía antes de validarlo, lo que reventaba al morir un enemigo
		# si el GameManager no estaba en el árbol
		if is_instance_valid(game_manager):
			var calculated_value: int = roundi((COINS_DROPPED_DEFAULT + Store.save[Store.DATA.COINS_BONUS] * 5) \
					* game_manager.upgrade_manager.get_coin_bonus())
			game_manager.add_gold(calculated_value)
		has_died.emit()
