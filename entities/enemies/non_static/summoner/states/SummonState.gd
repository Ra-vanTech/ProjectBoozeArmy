class_name EnemySummonState
extends State

@export var summoned_enemy: PackedScene
@export var amount: int = 1
@export var spawn_radius: float = 2.0
@export var summon_cooldown: float = 1.0

@export var owner_body: Node3D

@export_group("Transitions")
@export var default_next_state: String = "EnemyMovingState"
## Si es verdadero, evaluará si el jugador está en rango para pasar al estado de ataque.
@export var check_attack_range: bool = false
@export var attack_state_name: String = "EnemyAttackState"

var timer: Timer

func _ready() -> void:
	timer = Timer.new()
	timer.one_shot = true
	add_child(timer)
	timer.timeout.connect(_on_timer_timeout)

func enter() -> void:
	_summon()
	timer.start(summon_cooldown)

func exit() -> void:
	timer.stop()

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

func _on_timer_timeout() -> void:
	if check_attack_range and "player_in_range" in owner_body and is_instance_valid(owner_body.player_in_range):
		state_machine.change_state(attack_state_name)
	else:
		state_machine.change_state(default_next_state)
