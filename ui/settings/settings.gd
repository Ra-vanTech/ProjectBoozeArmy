extends CanvasLayer


func _ready() -> void:
	$TransitionScreen/AnimationPlayer.play("fade_out")


func _on_button_pressed() -> void:
	$TransitionScreen.show()
	$TransitionScreen/AnimationPlayer.play("fade_in")
	$TransitionScreen/Timer.start()


func _on_timer_timeout() -> void:
	get_tree().change_scene_to_file("res://ui/menu_screen/main_menu.tscn")
