extends CanvasLayer


func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_continue_button_pressed() -> void:
	Engine.time_scale = 1
	visible = false


func _visibility_changed():
	pass
