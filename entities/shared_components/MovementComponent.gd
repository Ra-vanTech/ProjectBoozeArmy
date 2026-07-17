class_name MovementComponent
extends Node

@export var BODY: CharacterBody3D
@export var MODEL: Node3D
@export var MOVEMENT_SPEED: float = 5.0
@export var GRAVITY_MULTIPLIEAR: float = 3.0

var direction: Vector2 = Vector2.ZERO

@onready var calculated_speed: float = MOVEMENT_SPEED + Store.save[Store.DATA.BASE_SPD]


func tick(delta: float) -> void:
	if not BODY:
		return
	if delta == 0.0:
		return

	BODY.velocity.x = direction.x * calculated_speed
	BODY.velocity.z = direction.y * calculated_speed

	if not BODY.is_on_floor():
		BODY.velocity += BODY.get_gravity() * delta * GRAVITY_MULTIPLIEAR

	BODY.move_and_slide()
	if MODEL and direction.length_squared() > 0.001:
		var look_direction: Vector3 = Vector3(direction.x, 0, direction.y).normalized()
		MODEL.look_at(MODEL.global_position + look_direction, Vector3.UP)
