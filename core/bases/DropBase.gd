class_name DropBase
extends Node

var bonus_amount: int

@onready var game_manager: GameManager = get_tree().get_first_node_in_group("game_manager")


func pickup() -> void:
	pass
