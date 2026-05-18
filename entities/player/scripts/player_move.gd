extends CharacterBody3D

@export var speed: float = 6.0
@export var accel: float = 15.0
@export var push_strength: float = 1.0
@export var jump_velocity: float = 5.0
@export var projectile_speed: float = 20.0

var gravity: float = float(ProjectSettings.get_setting("physics/3d/default_gravity"))

# Precargar la escena del proyectil
const PROJECTILE_SCENE: PackedScene = preload("res://scenes/weapons/projectile.tscn")

@onready var camera: Camera3D = $Camera3D

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

	# Sistema de disparo
	if Input.is_action_just_pressed("shoot"):
		shoot()

	if Input.is_action_just_pressed("quit"):
		get_tree().quit()

func shoot() -> void:
	if not camera:
		return

	# Crear instancia del proyectil
	var projectile: RigidBody3D = PROJECTILE_SCENE.instantiate()

	# Agregar el proyectil a la escena (como hijo del root)
	get_tree().root.add_child(projectile)

	# Posicionar el proyectil desde el cilindro del jugador
	# Offset vertical para que salga del centro del cilindro
	var spawn_height_offset: float = 1.2
	projectile.global_position = global_position + Vector3(0, spawn_height_offset, 0)

	# Calcular dirección de disparo basada en la cámara
	# Proyectar la dirección de la cámara en el plano horizontal (XZ)
	var cam_forward: Vector3 = -camera.global_transform.basis.z
	var shoot_direction: Vector3 = Vector3(cam_forward.x, 0, cam_forward.z).normalized()

	# Si no hay dirección horizontal, disparar hacia adelante del transform del jugador
	if shoot_direction.length() < 0.1:
		shoot_direction = -transform.basis.z

	# Lanzar el proyectil
	projectile.launch(shoot_direction)
