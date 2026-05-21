class_name HealthComponent
extends Node

signal has_died

@export var STARTING_HEALTH: float = 100.0
@export var COINS_DROPPED_DEFAULT: int = 25

var health: float
var coins_dropped: int

@onready var bank_label: Bank = get_tree().get_first_node_in_group("bank")


func _ready() -> void:
	health = STARTING_HEALTH
	coins_dropped = COINS_DROPPED_DEFAULT


func damage(attack: Attack):
	health -= attack.damage
	print(health)

	if health <= 0:
		bank_label.gold += coins_dropped
		has_died.emit()
