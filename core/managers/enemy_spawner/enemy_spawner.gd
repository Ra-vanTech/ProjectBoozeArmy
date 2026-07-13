class_name EnemySpawner
extends Node3D

@export var enemy: PackedScene
@export var spawn_delay: float = 10.0 # Después de cuánto tiempo va a aparecer el enemigo
# Anillo de aparición alrededor del jugador
@export_range(1, 19) var MIN_SPAWN_DISTANCE: float = 12.0 # distancia mínima al jugador
@export_range(19, 50) var MAX_SPAWN_DISTANCE: float = 22.0 # distancia máxima al jugador

# El piso es 50x50 centrado en el origen; dejamos 1u de margen para que los
# enemigos no aparezcan sobre el borde y se caigan del mapa
const MAP_LIMIT: float = 24.0
# Altura de aparición ligeramente elevada: una caída corta es inofensiva,
# aparecer incrustado en el piso provoca lanzamientos al cielo
const SPAWN_HEIGHT: float = 1.5

var timer: Timer
var spawn_cooldown: float = 3.0
var spawn_amount: int = 1

@onready var game_manager: GameManager = get_tree().get_first_node_in_group("game_manager")


func _ready() -> void:
	timer = Timer.new()
	timer.one_shot = false
	timer.wait_time = spawn_cooldown
	add_child(timer)
	timer.timeout.connect(spawn_enemy)
	timer.start()


func spawn_enemy() -> void:
	if game_manager.game_ended:
		timer.stop()
		return
	if spawn_delay > 0.0:
		var time_elapsed = game_manager.difficulty_manager.timer.wait_time - game_manager.difficulty_manager.timer.time_left
		if time_elapsed < spawn_delay:
			return

	# Aparición relativa al jugador (si existe); si no, respecto al spawner
	var player: Node3D = get_tree().get_first_node_in_group("player") as Node3D
	var origin: Vector3 = player.global_position if is_instance_valid(player) else global_position

	for i in range(spawn_amount):
		var new_enemy = enemy.instantiate() as Enemy
		new_enemy.COINS_DROPPED *= game_manager.difficulty_manager.get_money_mult()
		new_enemy.speed_multiplier = game_manager.difficulty_manager.get_speed_mult()

		# Escalado de vida por dificultad (respeta scaling_enabled internamente)
		new_enemy.health *= game_manager.difficulty_manager.get_health_mult()
		#Modificador de hp - enemigos -10% por stack
		new_enemy.health *= game_manager.upgrade_manager.get_enemy_hp()

		add_child(new_enemy)
		# La posición se asigna tras add_child para que global_position sea fiable
		new_enemy.global_position = _random_spawn_position(origin)

		# Conectar XP al morir, la señal pasa xp_value directamente a add_xp
		# new_enemy.enemy_died.connect(game_manager.add_xp)

	timer.wait_time = maxf(0.05, game_manager.difficulty_manager.get_spawn_rate())
	spawn_amount = game_manager.difficulty_manager.get_spawn_amount()


# Devuelve un punto en un anillo alrededor del origen, recortado a los límites del mapa
func _random_spawn_position(origin: Vector3) -> Vector3:
	var angle: float = randf() * TAU
	var distance: float = randf_range(MIN_SPAWN_DISTANCE, MAX_SPAWN_DISTANCE)
	var x: float = clampf(origin.x + cos(angle) * distance, -MAP_LIMIT, MAP_LIMIT)
	var z: float = clampf(origin.z + sin(angle) * distance, -MAP_LIMIT, MAP_LIMIT)
	return Vector3(x, SPAWN_HEIGHT, z)
