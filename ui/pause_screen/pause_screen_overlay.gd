extends CanvasLayer

signal game_resumed


func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_continue_button_pressed() -> void:
	game_resumed.emit()


func _visibility_changed():
	pass
	visible = false
