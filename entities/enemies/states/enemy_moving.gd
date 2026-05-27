class_name EnemyMovingState
extends State

@onready var movement: MovementComponent = %MovementComponent
@onready var input: SeekingComponent = %SeekingComponent


func tick(delta: float):
	input.tick()
	if input.direction.length_squared() < 0.0001:
		state_machine.change_state("EnemyIdleState")
	movement.direction = input.direction
	movement.tick(delta)
