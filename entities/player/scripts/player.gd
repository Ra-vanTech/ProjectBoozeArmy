class_name Player
extends CharacterBody3D

# Precargar la escena del proyectil
const PROJECTILE_SCENE: PackedScene = preload("res://entities/weapons/scenes/projectile.tscn")

@onready var input_component: InputComponent = %InputComponent
@onready var movement_component: MovementComponent = %MovementComponent
@onready var hit_box_component: HitBoxComponent = $HitBoxComponent


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	input_component.update()
	movement_component.direction = input_component.move_direction
	movement_component.is_jumping = input_component.is_jumping
	movement_component.tick(delta)

	# all mish-mashed together just to see if it works, it sort of does, it doesnt work if not moving
	# Sistema de disparo
	if input_component.is_shooting:
		shoot()

	if input_component.has_quit:
		get_tree().quit()


func shoot() -> void:
	# Crear instancia del proyectil
	var projectile: RigidBody3D = PROJECTILE_SCENE.instantiate()
	# Agregar el proyectil a la escena (como hijo del root)
	get_tree().root.add_child(projectile)

	# Posicionar el proyectil desde el cilindro del jugador
	# Offset vertical para que salga del centro del cilindro
	var spawn_height_offset: float = 1.2
	projectile.global_position = global_position + Vector3(input_component.move_direction.x, spawn_height_offset, input_component.move_direction.y).normalized()

	# Calcular dirección de disparo segun el ese del input, por ahora no sé apuntar con la cámara
	var shoot_direction: Vector3 = Vector3(input_component.move_direction.x, 0, input_component.move_direction.y).normalized()

	# Lanzar el proyectil
	projectile.launch(shoot_direction)


func damage(attack: Attack):
	hit_box_component.damage(attack)
