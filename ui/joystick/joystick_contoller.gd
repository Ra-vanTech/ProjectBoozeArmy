class_name Joystick
extends Control

static var direction: Vector2 = Vector2.ZERO

@export var auto_hide: bool = true
@export var movable: bool = true

var has_moved: bool = false

@onready var circle = $JoystickCircle
@onready var point = $JoystickDot


static func get_direction() -> Vector2:
	return direction.normalized()


func _ready() -> void:
	if auto_hide and direction == Vector2.ZERO:
		visible = false


func _input(event: InputEvent) -> void:
	var center_pos = global_position + Vector2(80, 80) / 2
	if event is InputEventScreenDrag:
		if auto_hide:
			visible = true
		var is_on_left_side: bool = event.position.x < get_viewport_rect().size.x / 2

		if not is_on_left_side:
			pass

		if not has_moved and movable:
			if is_on_left_side:
				global_position = event.position
			else:
				global_position = get_viewport_rect().size / 2
			has_moved = true

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
		if movable:
			has_moved = false
		if auto_hide:
			visible = false
