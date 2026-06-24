class_name EnemySpawner
extends Node3D

@export var enemy: PackedScene
@export var difficulty_manager: DifficultyManager

var timer: Timer
var spawn_cooldown: float = 3.0
var spawn_amount: int = 1


func _ready() -> void:
	timer = Timer.new()
	timer.one_shot = false
	timer.wait_time = spawn_cooldown
	add_child(timer)
	timer.timeout.connect(spawn_enemy)
	timer.start()


func spawn_enemy() -> void:
	#Conteo de enemigos activos para aplicar el cap 
	var active_enemies: int = get_tree().get_nodes_in_group("enemies").size()
	var cap: int = difficulty_manager.get_enemy_cap()
	print("[CAP] Activos: %d | Cap actual: %d | game_progress: %.2f" % [active_enemies, cap, difficulty_manager.game_progress()])


	for i in range(spawn_amount):
		if active_enemies >= cap:
			break
		var new_enemy = enemy.instantiate() as Enemy
		new_enemy.health *= difficulty_manager.get_health_mult()
		new_enemy.COINS_DROPPED *= difficulty_manager.get_money_mult()
		new_enemy.enemy_speed *= difficulty_manager.get_speed_mult()
		print("[TEST] health_mult: %.2f | HP resultante: %.1f" % [difficulty_manager.get_health_mult(), new_enemy.health])
		add_child(new_enemy)
		new_enemy.global_position = global_position + Vector3(randi_range(-20, 20), 2, randi_range(-20, 20))
		
	timer.wait_time = difficulty_manager.get_spawn_rate()
	spawn_amount = difficulty_manager.get_spawn_amount()
