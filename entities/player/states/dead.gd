class_name DeadState
extends State

@onready var death_screen: CanvasLayer = get_tree().get_first_node_in_group("death_screen")


func enter():
	print("Cambiando a estado de muerto")
	get_tree().paused = true
	death_screen.visible = true
