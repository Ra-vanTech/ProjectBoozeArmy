class_name IdleState
extends State

@export var body: Player

@onready var input_component: InputComponent = %InputComponent


func tick(delta: float):
	input_component.update()
	if not body.is_on_floor():
		state_machine.change_state("FallingState")
	if input_component.is_jumping:
		state_machine.change_state("JumpingState")
	if input_component.move_direction.length_squared() > 0.0001:
		state_machine.change_state("MovingState")


func exit():
	print("Saliendo del estado inactivo")


func enter():
	print("Entrando al estado inactivo")
