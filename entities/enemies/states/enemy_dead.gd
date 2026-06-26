class_name EnemyDeadState
extends State

@export var parent: EnemyBase


func enter():
	print("Enemigo eliminado_xp: ", parent.xp_value)
	parent.enemy_died.emit(parent.xp_value)
	parent.queue_free()
