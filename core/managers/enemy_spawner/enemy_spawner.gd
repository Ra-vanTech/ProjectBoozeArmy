class_name EnemySpawner
extends Node3D

@export var enemy: PackedScene
@export var spawn_delay: float = 10.0 # Después de cuánto tiempo va a aparecer el enemigo
@export_range(1, 19) var MIN_SPAWN_DISTANCE = 5
@export_range(19, 50) var MAX_SPAWN_DISTANCE = 20

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
	for i in range(spawn_amount):
		var new_enemy = enemy.instantiate() as Enemy
		#new_enemy.health *= difficulty_manager.get_health_mult()
		new_enemy.COINS_DROPPED *= game_manager.difficulty_manager.get_money_mult()
		new_enemy.speed_multiplier = game_manager.difficulty_manager.get_speed_mult()

		#Modificador de hp - enemigos -10% por stack
		new_enemy.health *= game_manager.upgrade_manager.get_enemy_hp()

		add_child(new_enemy)
		new_enemy.global_position = global_position + Vector3(get_spawn_range(randi_range(-20, 20)), 1, get_spawn_range(randi_range(-20, 20)))

		# Conectar XP al morir, la señal pasa xp_value directamente a add_xp
		# new_enemy.enemy_died.connect(game_manager.add_xp)

	timer.wait_time = game_manager.difficulty_manager.get_spawn_rate()
	spawn_amount = game_manager.difficulty_manager.get_spawn_amount()


# Evita que los enemigos aparezcan fuera del rango especificado por MIN_SPAWN_DISTANCE y MAX_SPAWN_DISTANCE
func get_spawn_range(pos: int) -> int:
	if pos < 0:
		return clamp(pos, -MAX_SPAWN_DISTANCE, -MIN_SPAWN_DISTANCE)
	# si se optiene un 0, el enemigo aparecería en el centro
	# con clamp, se fuerza a aparecer a la distancia mínima
	return clamp(pos, MIN_SPAWN_DISTANCE, MAX_SPAWN_DISTANCE)
