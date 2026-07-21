class_name EnemyAttackState
extends State

@export var attack_cooldown: float = 1.0
@export var miss_cooldown: float = 0.5

var target: Player = null
var timer: Timer


func _ready() -> void:
	timer = Timer.new()
	timer.one_shot = true
	add_child(timer)
	timer.timeout.connect(on_timer_timeout)

@onready var enemy: Enemy = owner as Enemy


# Se quedan quietos por un momento después de atacar para que no se acerquen demasiado y terminen dentro del jugador
func enter():
	target = enemy.player_in_range as Player
	if not attempt_attack():
		timer.start(miss_cooldown)
	else:
		timer.start(attack_cooldown)

func attempt_attack() -> bool:
	if not is_instance_valid(target):
		target = null
		return false
	target.damage()
	return true


func on_timer_timeout():
	state_machine.change_state("EnemyMovingState")

func exit():
	timer.stop()
