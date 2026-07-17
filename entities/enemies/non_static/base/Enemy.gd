class_name Enemy
extends EnemyBase

# Con el mapa toroidal los enemigos que quedan atrás no deben acumularse:
# más allá de esta distancia se eliminan silenciosamente (sin drops)
const DESPAWN_DISTANCE: float = 60.0

#variables de referencia mientras el jugador esta en contacto
var can_attack: bool = true
var player_in_range: Node3D = null

var _despawn_frames: int = 0

@onready var hit_box_component: HitBoxComponent = %HitBoxComponent
@onready var movement_component: MovementComponent = %MovementComponent
@onready var seeking_component: SeekingComponent = %SeekingComponent
@onready var enemy_attack_range: Area3D = %EnemyAttackRange
@onready var state_machine: StateMachine = %StateMachine


func _ready() -> void:
	if movement_component:
		movement_component.MOVEMENT_SPEED *= speed_multiplier
	hit_box_component.health_component.health = health
	hit_box_component.health_component.COINS_DROPPED_DEFAULT = COINS_DROPPED


# La lógica termina en move_and_slide(), por lo que debe correr en el paso
# de física (igual que el jugador y los enanos) para evitar jitter y
# lecturas poco fiables de is_on_floor()
func _physics_process(delta: float) -> void:
	state_machine.tick(delta)

	# Despawn por distancia (chequeo barato: cada 30 frames)
	_despawn_frames += 1
	if _despawn_frames >= 30:
		_despawn_frames = 0
		if can_spawn:
			var player := get_tree().get_first_node_in_group("player") as Node3D
			if is_instance_valid(player) and global_position.distance_to(player.global_position) > DESPAWN_DISTANCE:
				queue_free()


func damage(attack: Attack) -> void:
	hit_box_component.damage(attack)


func _on_health_component_has_died() -> void:
	state_machine.change_state("EnemyDeadState")


# Funciones para detectar que el player aun se encuentra en su rango de ataque
func _on_enemy_attack_range_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		player_in_range = body


func _on_enemy_attack_range_body_exited(body: Node3D) -> void:
	if body.is_in_group("player") and player_in_range == body:
		player_in_range = null
