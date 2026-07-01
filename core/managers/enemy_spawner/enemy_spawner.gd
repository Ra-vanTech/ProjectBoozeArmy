class_name EnemySpawner
extends Node3D

@export var enemy: PackedScene

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
	for i in range(spawn_amount):
		var new_enemy = enemy.instantiate() as Enemy
		#new_enemy.health *= difficulty_manager.get_health_mult()
		new_enemy.COINS_DROPPED *= game_manager.difficulty_manager.get_money_mult()
		new_enemy.speed_multiplier = game_manager.difficulty_manager.get_speed_mult()

		#Modificador de hp - enemigos -10% por stack
		new_enemy.health *= game_manager.upgrade_manager.get_enemy_hp()

		add_child(new_enemy)
		new_enemy.global_position = global_position + Vector3(randi_range(-20, 20), 2, randi_range(-20, 20))

		# Conectar XP al morir, la señal pasa xp_value directamente a add_xp
		new_enemy.enemy_died.connect(game_manager.xp_manager.add_xp)

	timer.wait_time = game_manager.difficulty_manager.get_spawn_rate()
	spawn_amount = game_manager.difficulty_manager.get_spawn_amount()
