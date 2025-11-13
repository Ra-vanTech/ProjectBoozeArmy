extends CharacterBody3D

@export var speed: float = 6.0
@export var accel: float = 15.0
@export var push_strength: float = 1.0
@export var jump_velocity: float = 5.0

var gravity: float = float(ProjectSettings.get_setting("physics/3d/default_gravity"))

func _physics_process(delta: float) -> void:
	# Gravedad
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Salto
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	# Entrada WASD
	var input_vec: Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var wish_dir: Vector3 = (transform.basis * Vector3(input_vec.x, 0.0, input_vec.y)).normalized()

	var target_vel: Vector3 = wish_dir * speed
	velocity.x = move_toward(velocity.x, target_vel.x, accel * delta)
	velocity.z = move_toward(velocity.z, target_vel.z, accel * delta)

	move_and_slide()


	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
