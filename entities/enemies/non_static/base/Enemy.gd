class_name Enemy
extends EnemyBase

@export var health: float = 100.0
@export var COINS_DROPPED: int = 25
@export var state_machine: StateMachine

@onready var hit_box_component: HitBoxComponent = %HitBoxComponent
@onready var movement_component: MovementComponent = %MovementComponent
@onready var seeking_component: SeekingComponent = %SeekingComponent


func _ready() -> void:
	hit_box_component.health_component.health = health
	hit_box_component.health_component.COINS_DROPPED_DEFAULT = COINS_DROPPED


func _process(delta: float) -> void:
	seeking_component.tick()
	movement_component.direction = seeking_component.direction
	movement_component.tick(delta)


func damage(attack: Attack) -> void:
	hit_box_component.damage(attack)


func _on_health_component_has_died() -> void:
	queue_free()
