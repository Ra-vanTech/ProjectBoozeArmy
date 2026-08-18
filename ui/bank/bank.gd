class_name Bank
extends Label

@onready var game_manager: GameManager = Services.game_manager


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	game_manager.money_manager.gold_changed.connect(on_gold_changed)
	game_manager.add_gold(0)


func on_gold_changed(new_gold: int) -> void:
	text = "Gold: " + str(new_gold)
