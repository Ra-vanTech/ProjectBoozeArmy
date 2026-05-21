class_name EnemySpawner
extends Node3D

@export var enemy: PackedScene

var timer: Timer
var spawn_cooldown: float = 1.0
var spawn_amount: int


func _ready() -> void:
	timer = Timer.new()
	timer.one_shot = false
	timer.wait_time = spawn_cooldown
	add_child(timer)
	timer.timeout.connect(spawn_enemy)
	timer.start()


func spawn_enemy() -> void:
	print("ola, soi un enemigo")
