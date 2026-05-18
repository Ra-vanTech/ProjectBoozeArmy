extends RigidBody3D

@onready var hit_box_component: HitBoxComponent = %HitBoxComponent

func damage(attack: Attack):
	hit_box_component.damage(attack)
