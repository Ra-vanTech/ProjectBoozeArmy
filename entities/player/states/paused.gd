class_name PausedState
extends State


func enter():
	Events.pausa_cambiada.emit(true)
	get_parent().get_parent().set_physics_process(false)
	get_tree().paused = true


func exit():
	get_parent().get_parent().set_physics_process(true)
	Events.pausa_cambiada.emit(false)
	get_tree().paused = false
