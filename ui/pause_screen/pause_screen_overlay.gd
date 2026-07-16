extends CanvasLayer

signal game_resumed


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED


func _on_quit_button_pressed() -> void:
	# get_tree().paused = false
	var money_manager: MoneyManager = get_tree().get_first_node_in_group("game_manager").money_manager
	Store.save[Store.DATA.GOLD] += money_manager.gold
	Store.save_data()
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
