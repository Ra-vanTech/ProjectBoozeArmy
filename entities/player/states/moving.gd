class_name MovingState
extends State

@onready var movement_component: MovementComponent = %MovementComponent
@onready var input_component: InputComponent = %InputComponent


func tick(delta: float):
	input_component.update()
	if input_component.move_direction.length_squared() < 0.0001:
		state_machine.change_state("IdleState")
	movement_component.direction = input_component.move_direction
	movement_component.is_jumping = input_component.is_jumping
	movement_component.tick(delta)


func enter():
	# Animación de movimiento
	pass


func exit():
	# Algo
	pass
