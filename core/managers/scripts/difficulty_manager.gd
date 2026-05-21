class_name DifficultyManager
extends Node

signal game_ended

@export var spawn_rate_curve: Curve
@export var spawn_amount_curve: Curve
@export var health_multiplier_curve: Curve
@export var money_multiplier_curve: Curve
@export var game_time := 300.0

var timer: Timer


func _ready() -> void:
	timer = Timer.new()
	timer.wait_time = game_time
	timer.one_shot = true
	add_child(timer)
	timer.timeout.connect(on_game_ended)


func game_progress() -> float:
	return 1.0 - (timer.time_left / game_time)


func get_spawn_rate() -> int:
	return floor(spawn_amount_curve.sample(game_progress()))


func get_spawn_amount() -> float:
	return spawn_amount_curve.sample(game_progress())


func get_health_mult() -> float:
	return health_multiplier_curve.sample(game_progress())


func get_money_mult() -> float: # también es una posibilidad que el dinero ganado sea directamente proporcional a la salud, lo que haría que usen la misma curva
	return money_multiplier_curve.sample(game_progress())


func on_game_ended() -> void:
	game_ended.emit()
