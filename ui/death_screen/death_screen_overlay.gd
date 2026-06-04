extends CanvasLayer


func _on_quit_button_pressed() -> void:
	Engine.time_scale = 1
	$TransitionScreen.show()
	$TransitionScreen/AnimationPlayer.play("fade_in")
	$TransitionScreen/Timer.start()


func _on_retry_button_pressed() -> void:
	get_tree().reload_current_scene()


func _on_timer_timeout() -> void:
	get_tree().change_scene_to_file("res://ui/menu_screen/main_menu.tscn")
