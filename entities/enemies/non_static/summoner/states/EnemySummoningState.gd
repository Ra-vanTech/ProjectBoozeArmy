# Reemplaza a EnemyAttackState para el invocador
class_name EnemySummoningState
extends State

@export var summoned_enemy: PackedScene
@export var amount: int = 1
@export var spawn_radius: float = 2.0
@export var summon_cooldown: float = 1.0

var timer: Timer
@export var owner_body: Node3D

func _ready() -> void:
	timer = Timer.new()
	timer.one_shot = true
	add_child(timer)
	timer.timeout.connect(on_timer_timeout)

func enter():
	print("[Summoner]: Invocando enemigos")
	_summon()
	timer.start(summon_cooldown)

func _summon() -> void:
	if not summoned_enemy or not is_instance_valid(owner_body):
		return
	
	var world_parent = owner_body.get_parent()
	if not is_instance_valid(world_parent):
		return
	
	for i in range(amount):
		var new_enemy := summoned_enemy.instantiate() as Node3D
		world_parent.add_child(new_enemy)
		new_enemy.global_position = _random_position(owner_body.global_position)

func _random_position(origin: Vector3) -> Vector3:
	var angle := randf() * TAU
	var distance := randf_range(1.0, spawn_radius)
	return origin + Vector3(cos(angle) * distance, 0.0, sin(angle) * distance)

func on_timer_timeout():
	state_machine.change_state("EnemyMovingState")

func exit():
	print("[Summoner]: Saliendo de estado de invocación")

