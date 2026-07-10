class_name XpBar
extends Label

var current_level: int = 1

@onready var game_manager: GameManager = get_tree().get_first_node_in_group("game_manager")


func _ready() -> void:
	game_manager.xp_manager.xp_gained.connect(on_xp_changed)
	game_manager.xp_manager.level_up.connect(on_level_up)
	game_manager.xp_manager.max_level_reached.connect(on_max_level_reached)
	game_manager.add_xp(0)


func on_xp_changed(new_xp: int, required_xp: int) -> void:
	# IMPLEMENTACIÓN TEMPORAL, lo más óptimo sería tener 2 etiquetas distintas que muestren cada cosa
	text = "Nivel " + str(current_level) + "\n" + str(new_xp) + " / " + str(required_xp)


func on_level_up(new_level: int) -> void:
	current_level = new_level


func on_max_level_reached() -> void:
	text = "MAX"
