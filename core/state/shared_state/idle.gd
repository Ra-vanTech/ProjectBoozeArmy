class_name IdleState
extends State

@export var input_component: InputComponent


func tick(delta: float):
	input_component.update()
	if input_component.is_jumping:
		state_machine.change_state("JumpingState")
	if input_component.move_direction.length_squared() > 0.0001:
		state_machine.change_state("MovingState")


func exit():
	print("Saliendo del estado inactivo")


func enter():
	print("Entrando al estado inactivo")
