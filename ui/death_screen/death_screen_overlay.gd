extends CanvasLayer


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED


func _on_quit_button_pressed() -> void:
	# get_tree().paused = false
	$TransitionScreen.show()
	$TransitionScreen/AnimationPlayer.play("fade_in")
	$TransitionScreen/Timer.start()


func _on_retry_button_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_timer_timeout() -> void:
	get_tree().change_scene_to_file("res://ui/menu_screen/main_menu.tscn")
