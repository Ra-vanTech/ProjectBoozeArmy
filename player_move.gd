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

	# Entrada WASD
	var input_vec: Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var wish_dir: Vector3 = (transform.basis * Vector3(input_vec.x, 0.0, input_vec.y)).normalized()

	var target_vel: Vector3 = wish_dir * speed
	velocity.x = move_toward(velocity.x, target_vel.x, accel * delta)
	velocity.z = move_toward(velocity.z, target_vel.z, accel * delta)

	move_and_slide()

	# Empuje a RigidBodies al colisionar
	var col_count: int = get_slide_collision_count()
	for i in range(col_count):
		var c: KinematicCollision3D = get_slide_collision(i)
		var rb := c.get_collider() as RigidBody3D
		if rb:
			var push_dir: Vector3 = Vector3(velocity.x, 0.0, velocity.z)
			if push_dir.length() > 0.0:
				rb.apply_central_impulse(push_dir * push_strength)

	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
