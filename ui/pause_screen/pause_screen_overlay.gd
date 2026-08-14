extends CanvasLayer


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	visible = false
	Events.pausa_cambiada.connect(_on_pausa_cambiada)


func _on_pausa_cambiada(en_pausa: bool) -> void:
	visible = en_pausa


func _on_quit_button_pressed() -> void:
	# get_tree().paused = false
	var money_manager: MoneyManager = Services.money
	if is_instance_valid(money_manager):
		Store.save[Store.DATA.GOLD] += money_manager.gold
	Store.save_data()
	$TransitionScreen.show()
	$TransitionScreen/AnimationPlayer.play("fade_in")
	$TransitionScreen/Timer.start()


func _on_continue_button_pressed() -> void:
	Events.reanudacion_solicitada.emit()


func _on_timer_timeout() -> void:
	get_tree().change_scene_to_file("res://ui/menu_screen/main_menu.tscn")
