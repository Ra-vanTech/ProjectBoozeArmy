class_name Enemy
extends EnemyBase

@export var health: float = 100.0
@export var COINS_DROPPED: int = 25

@onready var hit_box_component: HitBoxComponent = %HitBoxComponent
@onready var movement_component: MovementComponent = %MovementComponent
@onready var seeking_component: SeekingComponent = %SeekingComponent
@onready var state_machine: StateMachine = %StateMachine


func _ready() -> void:
	hit_box_component.health_component.health = health
	hit_box_component.health_component.COINS_DROPPED_DEFAULT = COINS_DROPPED


func _process(delta: float) -> void:
	state_machine.tick(delta)


func damage(attack: Attack) -> void:
	hit_box_component.damage(attack)


func _on_health_component_has_died() -> void:
	queue_free()
