class_name Enemy
extends EnemyBase

@onready var hit_box_component: HitBoxComponent = %HitBoxComponent
@onready var movement_component: MovementComponent = %MovementComponent
@onready var seeking_component: SeekingComponent = %SeekingComponent


func _process(delta: float) -> void:
	seeking_component.tick()
	movement_component.direction = seeking_component.direction
	movement_component.tick(delta)


func damage(attack: Attack) -> void:
	hit_box_component.damage(attack)


func _on_health_component_has_died() -> void:
	queue_free()
