class_name Enemy
extends EnemyBase

@export var STARTING_HEALTH := 100.0
@export var COINS_DROPPED := 25

@onready var hit_box_component: HitBoxComponent = %HitBoxComponent
@onready var movement_component: MovementComponent = %MovementComponent
@onready var seeking_component: SeekingComponent = %SeekingComponent


func _ready() -> void:
	hit_box_component.health_component.STARTING_HEALTH = STARTING_HEALTH
	hit_box_component.health_component.COINS_DROPPED_DEFAULT = COINS_DROPPED


func _process(delta: float) -> void:
	seeking_component.tick()
	movement_component.direction = seeking_component.direction
	movement_component.tick(delta)


func damage(attack: Attack) -> void:
	hit_box_component.damage(attack)


func _on_health_component_has_died() -> void:
	queue_free()
