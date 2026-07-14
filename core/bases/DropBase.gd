class_name DropBase
# Los drops viven en el mundo 3D (sus escenas usan StaticBody3D como raíz);
# declarar Node3D permite a las subclases usar global_position
extends Node3D

var bonus_amount: int

@onready var game_manager: GameManager = get_tree().get_first_node_in_group("game_manager")


func pickup() -> void:
	pass
