class_name DifficultyManager
extends Node

signal game_ended

#trigger de tiempo [es para el boss]
signal boss_spawned

@export var boss_spawn_time: float = 10.0
var _boss_spawn_emitted: bool = false

@export var spawn_rate_curve: Curve
@export var spawn_amount_curve: Curve
@export var health_multiplier_curve: Curve
@export var money_multiplier_curve: Curve
@export var game_time := 300.0
@export var scaling_enabled: bool = true

var timer: Timer
var time_elapsed_timer: Timer
var time_elapsed: int = 0


func _ready() -> void:
	timer = Timer.new()
	add_child(timer)
	timer.wait_time = game_time
	timer.one_shot = true
	timer.timeout.connect(on_game_ended)
	timer.start()

	time_elapsed_timer = Timer.new()
	add_child(time_elapsed_timer)
	time_elapsed_timer.wait_time = 1.0
	time_elapsed_timer.one_shot = false
	time_elapsed_timer.timeout.connect(add_time)
	time_elapsed_timer.start()


func game_progress() -> float:
	return 1.0 - (timer.time_left / game_time)


# Con el escalado desactivado, todas las curvas se congelan en su valor inicial
func _progress() -> float:
	return game_progress() if scaling_enabled else 0.0


func get_spawn_rate() -> float:
	return spawn_rate_curve.sample(_progress())


func get_spawn_amount() -> int:
	return floori(spawn_amount_curve.sample(_progress()))


func get_health_mult() -> float:
	return health_multiplier_curve.sample(_progress())


func get_money_mult() -> float: # también es una posibilidad que el dinero ganado sea directamente proporcional a la salud, lo que haría que usen la misma curva
	return money_multiplier_curve.sample(_progress())


# +10% velocidad al minuto 2:00. Un unico evento
func get_speed_mult() -> float:
	if not scaling_enabled:
		return 1.0
	# var elapsed: float = game_time - timer.time_left
	if time_elapsed >= 120:
		# Aplicar multiplicador de velocidad
		return 1.1
	return 1.0


func add_time() -> void:
	time_elapsed += 1
	# print(time_elapsed)
	# Garantiza que se dispare la señal una vez por partida.
	if not _boss_spawn_emitted and time_elapsed >= boss_spawn_time:
		_boss_spawn_emitted = true
		boss_spawned.emit()


func on_game_ended() -> void:
	game_ended.emit()
