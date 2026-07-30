class_name PauseButton
extends Button

@onready var player: Player = get_tree().get_first_node_in_group("player")

func _ready() -> void:
	pressed.connect(_on_pressed)


func _on_pressed() -> void:
	player.request_pause()
