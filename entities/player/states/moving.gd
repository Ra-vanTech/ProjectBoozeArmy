class_name MovingState
extends State

@export var input_component: InputComponent
@export var movement_component: MovementComponent


func tick(delta: float):
	input_component.update()
	if input_component.is_jumping:
		state_machine.change_state("JumpingState")
	if input_component.move_direction.length_squared() < 0.0001:
		state_machine.change_state("IdleState")
	movement_component.direction = input_component.move_direction
	movement_component.is_jumping = input_component.is_jumping
	movement_component.tick(delta)


func enter():
	print("Entrando al estado de movimiento")


func exit():
	print("Saliendo del estado de movimiento")
