class_name JumpingState
extends State

@export var body: CharacterBody3D
@export var movement_component: MovementComponent


func tick(delta: float):
	movement_component.tick(delta)
	if body.velocity.y <= 0:
		print("cayendo")
		state_machine.change_state("FallingState")


func enter():
	movement_component.jump()
	print("Entrando al estado de salto")


func exit():
	print("Saliendo del estado de salto")
