class_name PauseButton
extends Button

@onready var player: Player = Services.player

func _ready() -> void:
	pressed.connect(_on_pressed)


func _on_pressed() -> void:
	player.request_pause()
