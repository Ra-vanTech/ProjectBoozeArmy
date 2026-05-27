class_name Player
extends CharacterBody3D

# Precargar la escena del proyectil
const PROJECTILE_SCENE: PackedScene = preload("res://entities/weapons/scenes/projectile.tscn")

@export var health := 100.0
@export var COINS_DROPPED := 0
@export var state_machine: StateMachine

@onready var input_component: InputComponent = %InputComponent
@onready var hit_box_component: HitBoxComponent = %HitBoxComponent
@onready var dwarf_system: DwarfSystem = %DwarfContainer


func _ready() -> void:
	Engine.time_scale = 1
	hit_box_component.health_component.health = health
	hit_box_component.health_component.COINS_DROPPED_DEFAULT = COINS_DROPPED


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	state_machine.tick(delta)

	# all mish-mashed together just to see if it works, it sort of does, it doesnt work if not moving
	# Sistema de disparo
	if input_component.is_shooting:
		shoot()

	if input_component.wants_spawn:
		dwarf_system.agregar_enano()

	if input_component.wants_despawn:
		dwarf_system.eliminar_enano()

	if input_component.has_quit:
		state_machine.change_state("PausedState")


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


func _on_health_component_has_died() -> void:
	state_machine.change_state("DeadState")


func _on_pause_screen_overlay_game_resumed() -> void:
	state_machine.change_state("IdleState")
