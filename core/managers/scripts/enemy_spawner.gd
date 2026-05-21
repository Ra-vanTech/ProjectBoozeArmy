class_name EnemySpawner
extends Node3D

@export var enemy: PackedScene
@export var difficulty_manager: DifficultyManager

var timer: Timer
var spawn_cooldown: float = 1.0
var spawn_amount: int = 1


func _ready() -> void:
	timer = Timer.new()
	timer.one_shot = false
	timer.wait_time = spawn_cooldown
	add_child(timer)
	timer.timeout.connect(spawn_enemy)
	timer.start()


func spawn_enemy() -> void:
	for i in range(spawn_amount):
		var new_enemy = enemy.instantiate()
		add_child(new_enemy)
		new_enemy.STARTING_HEALTH *= difficulty_manager.get_health_mult()
		new_enemy.COINS_DROPPED *= difficulty_manager.get_money_mult()
		new_enemy.global_position = global_position + Vector3(randi_range(-10, 10), 2, randi_range(-10, 10))
	timer.wait_time = difficulty_manager.get_spawn_rate()
	spawn_amount = difficulty_manager.get_spawn_amount()
