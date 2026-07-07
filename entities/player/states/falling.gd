class_name FallingState
extends State

@export var body: Player

@onready var movement_component: MovementComponent = %MovementComponent


func tick(delta: float):
	movement_component.tick(delta)
	if body.is_on_floor():
		state_machine.change_state("IdleState")


func enter():
	# Implementación de animación de caída
	pass


func exit():
	# Efecto de sonido al caer
	pass
