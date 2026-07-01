class_name EnemyDeadState
extends State

@export var parent: EnemyBase

var xp_orb = load("res://entities/drops/xp_drop/XpDrop.tscn")


func enter():
	print("Enemigo eliminado_xp: ", parent.xp_value)
	var new_xp_orb = xp_orb.instantiate() as XpDrop
	new_xp_orb.global_position = parent.global_position
	new_xp_orb.xp_amount = parent.xp_value
	parent.add_sibling(new_xp_orb)
	# parent.enemy_died.emit(parent.xp_value)
	parent.queue_free()
