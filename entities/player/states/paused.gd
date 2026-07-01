class_name PausedState
extends State

@onready var pause_screen = get_tree().get_first_node_in_group("pause_screen")


func enter():
	pause_screen.visible = true
	get_parent().get_parent().set_physics_process(false)
	get_tree().paused = true


func exit():
	get_parent().get_parent().set_physics_process(true)
	pause_screen.visible = false
	get_tree().paused = false
