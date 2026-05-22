class_name DeadState
extends State

@onready var death_screen: CanvasLayer = get_tree().get_first_node_in_group("death_screen")


func enter():
	print("Cambiando a estado de muerto")
	get_parent().get_parent().set_physics_process(false)
	Engine.time_scale = 0
	death_screen.visible = true
