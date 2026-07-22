class_name DrunkenessMeter
extends Label

const COLOR_CRITICO := Color(1.0, 0.25, 0.25)
const COLOR_RIESGO := Color(1.0, 0.6, 0.2)
const COLOR_NORMAL := Color.WHITE
const COLOR_EBRIO := Color(1.0, 0.85, 0.3)

# Último valor recibido, para mostrar la tendencia (▲ subiendo / ▼ bajando)
var _previous: int = -1

@onready var drunkeness_manager: DrunkenessManager = get_tree().get_first_node_in_group("game_manager").drunkeness_manager


# @onready var game_manager: GameManager = get_tree().get_first_node_in_group("game_manager") # aquí la verdad es más fácil usar el gestor de ebriedad directamente pero noc
func _ready() -> void:
	drunkeness_manager.drunkeness_changes.connect(on_drunkeness_changed)
	on_drunkeness_changed(drunkeness_manager.drunkeness)


func on_drunkeness_changed(input: int) -> void:
	var trend := ""
	if _previous >= 0 and input > _previous:
		trend = " ▲"
	elif _previous >= 0 and input < _previous:
		trend = " ▼"
	_previous = input

	var zona: String
	var color: Color
	if input == 0:
		zona = "¡SOBRIO! Pierdes enanos"
		color = COLOR_CRITICO
	elif input < DrunkenessManager.ZONA_SOBRIA:
		zona = "Casi sobrio (-30% daño)"
		color = COLOR_RIESGO
	elif input <= DrunkenessManager.ZONA_EBRIA:
		zona = "Normal"
		color = COLOR_NORMAL
	else:
		zona = "EBRIO (+30% daño, +vel.)"
		color = COLOR_EBRIO

	text = "Ebriedad: %d%s — %s" % [input, trend, zona]
	modulate = color
