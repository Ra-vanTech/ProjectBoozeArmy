class_name TimerUI
extends Label

@onready var game_manager: GameManager = Services.game_manager


func _ready() -> void:
	game_manager.difficulty_manager.time_elapsed_timer.timeout.connect(update_time)
	text = game_manager.get_time_elapsed()


func update_time() -> void:
	text = game_manager.get_time_elapsed()
