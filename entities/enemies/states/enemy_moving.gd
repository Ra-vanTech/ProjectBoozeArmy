class_name EnemyMovingState
extends State

@onready var movement: MovementComponent = %MovementComponent
@onready var input: SeekingComponent = %SeekingComponent
@onready var enemy: Enemy = owner as Enemy


func tick(delta: float):
	if is_instance_valid(enemy.player_in_range):
		state_machine.change_state("EnemyAttackingState")
		return

	input.tick()
	if input.direction.length_squared() < 0.0001:
		state_machine.change_state("EnemyIdleState")
	movement.direction = input.direction
	movement.tick(delta)
