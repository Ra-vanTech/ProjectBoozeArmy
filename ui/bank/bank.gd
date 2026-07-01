class_name Bank
extends Label

@onready var game_manager: GameManager = get_tree().get_first_node_in_group("game_manager")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	game_manager.money_manager.gold_changed.connect(on_gold_changed)
	text = "Gold: 0"


func on_gold_changed(new_gold: int) -> void:
	text = "Gold: " + str(new_gold)
