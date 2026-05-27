class_name EnemyMovingState
extends State

@onready var movement: MovementComponent = %MovementComponent
@onready var input: SeekingComponent = %SeekingComponent


func tick(delta: float):
	input.tick()
	movement.direction = input.direction
	movement.tick(delta)
