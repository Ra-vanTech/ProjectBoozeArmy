class_name Enemy
extends EnemyBase

# Con el mapa toroidal los enemigos que quedan atrás no deben acumularse:
# más allá de esta distancia se eliminan silenciosamente (sin drops)
const DESPAWN_DISTANCE: float = 60.0

#variables de referencia mientras el jugador esta en contacto
var can_attack: bool = true
var player_in_range: Node3D = null

var _despawn_frames: int = 0
# Cacheada para no buscar por grupo en cada comprobación de despawn: con
# decenas de enemigos vivos esas búsquedas se acumulan
var _player: Node3D

@onready var hit_box_component: HitBoxComponent = %HitBoxComponent
@onready var movement_component: MovementComponent = %MovementComponent
@onready var seeking_component: SeekingComponent = %SeekingComponent
@onready var enemy_attack_range: Area3D = %EnemyAttackRange
@onready var state_machine: StateMachine = %StateMachine


func _ready() -> void:
	aplicar_stats()
	if movement_component:
		if stats != null:
			movement_component.MOVEMENT_SPEED = stats.movement_speed
		movement_component.MOVEMENT_SPEED *= speed_multiplier
	_sincronizar_componentes()


## Propaga vida y oro a los componentes que los consumen. Se llama al arrancar
## y cada vez que el spawner reescala al enemigo.
func _sincronizar_componentes() -> void:
	hit_box_component.health_component.health = health
	hit_box_component.health_component.COINS_DROPPED_DEFAULT = COINS_DROPPED


## Escalado por dificultad y mejoras, aplicado por el spawner DESPUÉS de
## añadirlo al árbol. Antes se hacía mutando los campos justo antes de
## add_child; con las stats en un recurso eso ya no vale, porque _ready las
## vuelca encima y borraría el escalado.
func aplicar_escalado(mult_health: float, mult_coins: float, mult_speed: float) -> void:
	health *= mult_health
	COINS_DROPPED = roundi(COINS_DROPPED * mult_coins)
	if movement_component:
		movement_component.MOVEMENT_SPEED *= mult_speed
	_sincronizar_componentes()


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
			if not is_instance_valid(_player):
				_player = Services.player
			if is_instance_valid(_player) and global_position.distance_squared_to(_player.global_position) > DESPAWN_DISTANCE * DESPAWN_DISTANCE:
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
