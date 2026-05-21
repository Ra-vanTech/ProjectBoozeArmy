class_name MovementComponent
extends Node

@export var BODY: CharacterBody3D
@export var MODEL: Node3D
@export var MOVEMENT_SPEED: float = 300.0
@export var JUMP_VELOCITY: float = 10.0
@export var GRAVITY_MULTIPLIEAR: float = 3.0

var direction: Vector2 = Vector2.ZERO
var is_jumping: bool = false


func tick(delta: float) -> void:
	if not BODY:
		return

	BODY.velocity.x = direction.x * MOVEMENT_SPEED * delta
	BODY.velocity.z = direction.y * MOVEMENT_SPEED * delta

	if not BODY.is_on_floor():
		BODY.velocity += BODY.get_gravity() * delta * GRAVITY_MULTIPLIEAR

	if is_jumping and BODY.is_on_floor():
		BODY.velocity.y = JUMP_VELOCITY
	is_jumping = false

	BODY.move_and_slide()

	if MODEL and direction.length_squared() > 0.001:
		var look_direction: Vector3 = Vector3(direction.x, 0, direction.y).normalized()
		MODEL.look_at(MODEL.global_position + look_direction, Vector3.UP)
