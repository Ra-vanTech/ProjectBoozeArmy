class_name PausedState
extends State

@onready var pause_screen = get_tree().get_first_node_in_group("pause_screen")


func enter():
	print("Entrando al estado de pausa")
	pause_screen.visible = true
	get_parent().get_parent().set_physics_process(false)
	Engine.time_scale = 0


func exit():
	print("Saliendo del estado de pausa")
	get_parent().get_parent().set_physics_process(true)
	pause_screen.visible = false
	Engine.time_scale = 1
