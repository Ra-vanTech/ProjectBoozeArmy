class_name EnemyMovingState
extends State

@export var enemy_body: EnemyBase

@onready var movement: MovementComponent = %MovementComponent
@onready var input: SeekingComponent = %SeekingComponent


func tick(delta: float):
	input.tick()
	if input.direction.length_squared() < 0.0001:
		state_machine.change_state("EnemyIdleState")
	movement.direction = input.direction
	movement.tick(delta)


func _on_enemy_attack_range_body_entered(body: Node3D) -> void:
	state_machine.change_state("EnemyAttackingState")
