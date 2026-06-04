extends CanvasLayer

signal game_resumed


func _on_quit_button_pressed() -> void:
	Engine.time_scale = 1
	$TransitionScreen.show()
	$TransitionScreen/AnimationPlayer.play("fade_in")
	$TransitionScreen/Timer.start()


func _on_continue_button_pressed() -> void:
	game_resumed.emit()


func _visibility_changed():
	pass
	visible = false


func _on_timer_timeout() -> void:
	get_tree().change_scene_to_file("res://ui/menu_screen/main_menu.tscn")
