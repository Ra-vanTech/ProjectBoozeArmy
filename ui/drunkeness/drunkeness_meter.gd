class_name DrunkenessMeter
extends Label

@onready var drunkeness_manager: DrunkenessManager = get_tree().get_first_node_in_group("game_manager").drunkeness_manager


# @onready var game_manager: GameManager = get_tree().get_first_node_in_group("game_manager") # aquí la verdad es más fácil usar el gestor de ebriedad directamente pero noc
func _ready() -> void:
	drunkeness_manager.drunkeness_changes.connect(on_drunkeness_changed)
	drunkeness_manager.drunkeness += 0


func on_drunkeness_changed(input) -> void:
	text = "Ebriedad: " + str(input)
	modulate = Color.RED.lerp(Color.WHITE, float(input) / drunkeness_manager.max_drunkeness)
