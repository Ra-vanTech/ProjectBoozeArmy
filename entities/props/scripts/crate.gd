extends RigidBody3D

@export var health := 40.0
@export var COINS_DROPPED := 50

@onready var hit_box_component: HitBoxComponent = %HitBoxComponent


func _ready() -> void:
	hit_box_component.health_component.health = health
	hit_box_component.health_component.COINS_DROPPED_DEFAULT = COINS_DROPPED


func damage(attack: Attack):
	hit_box_component.damage(attack)


func _on_health_component_has_died() -> void:
	queue_free()
