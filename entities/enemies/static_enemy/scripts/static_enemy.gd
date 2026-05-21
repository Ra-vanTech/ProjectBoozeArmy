class_name StaticEnemy
extends EnemyBase

@onready var hit_box_component: HitBoxComponent = %HitBoxComponent


func damage(attack: Attack):
	hit_box_component.damage(attack)


func _on_health_component_has_died() -> void:
	print("petatiado")
	queue_free()
