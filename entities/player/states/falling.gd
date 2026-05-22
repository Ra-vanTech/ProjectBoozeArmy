class_name FallingState
extends State

@export var body: CharacterBody3D
@export var movement_component: MovementComponent


func tick(delta: float):
	movement_component.tick(delta)
	if body.is_on_floor():
		state_machine.change_state("IdleState")


func enter():
	print("cayendo")


func exit():
	print("Saliendo del estado de caída")
