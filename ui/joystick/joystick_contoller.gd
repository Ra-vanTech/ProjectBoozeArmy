class_name Joystick
extends Control

static var direction: Vector2 = Vector2.ZERO

@onready var circle = $JoystickCircle
@onready var point = $JoystickDot


static func get_direction() -> Vector2:
	return direction.normalized()


func _input(event: InputEvent) -> void:
	var center_pos = global_position + Vector2(80, 80) / 2
	if event is InputEventScreenDrag:
		var is_on_left_side: bool = event.position.x < get_viewport_rect().size.x / 2

		if not is_on_left_side:
			return

		var new_pos: Vector2 = event.position
		var circle_radius = circle.texture.get_size().x / 2
		var is_in_border: bool = center_pos.distance_to(new_pos) < circle_radius

		var dir = center_pos.direction_to(new_pos)

		if is_in_border:
			point.global_position = new_pos
		else:
			point.global_position = center_pos + dir * circle_radius

		direction = dir

	if event is InputEventScreenTouch and event.is_released():
		point.global_position = center_pos
		direction = Vector2.ZERO
