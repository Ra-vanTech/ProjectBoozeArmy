class_name MainMenu
extends CanvasLayer

@export var starting_level: PackedScene

var selected_button = null


func _ready() -> void:
	get_tree().paused = false
	$TransitionScreen/AnimationPlayer.play("fade_out")


func play_transition() -> void:
	$TransitionScreen.show()
	$TransitionScreen/AnimationPlayer.play("fade_in")
	$TransitionScreen/WaitTimer.start()


func _on_play_button_pressed() -> void:
	selected_button = "start"
	play_transition()


func _on_upgrade_button_pressed() -> void:
	selected_button = "upgrades"
	play_transition()


func _on_options_button_pressed() -> void:
	selected_button = "options"
	play_transition()


func _on_quit_button_pressed() -> void:
	get_tree().quit()
	play_transition()


func _on_wait_timer_timeout() -> void:
	if selected_button == "start":
		get_tree().change_scene_to_packed(starting_level)
	elif selected_button == "options":
		get_tree().change_scene_to_file("res://ui/settings/settings.tscn")
	elif selected_button == "upgrades":
		get_tree().change_scene_to_file("res://ui/upgrade_store/upgrade_store.tscn")
