class_name HealthComponent extends Node


@export var MAX_HEALTH: float = 100.0
var health:float

func _ready() -> void:
	health = MAX_HEALTH

func damage(attack: Attack):
	health -= attack.damage
	print(health)

	if health <= 0:
		get_parent().queue_free()
