class_name StaticEnemy
extends EnemyBase

@export var STARTING_HEALTH := 100.0
@export var COINS_DROPPED := 25

@onready var hit_box_component: HitBoxComponent = %HitBoxComponent


func _ready() -> void:
	hit_box_component.health_component.STARTING_HEALTH = STARTING_HEALTH
	hit_box_component.health_component.COINS_DROPPED_DEFAULT = COINS_DROPPED


func damage(attack: Attack):
	hit_box_component.damage(attack)


func _on_health_component_has_died() -> void:
	print("petatiado")
	queue_free()
