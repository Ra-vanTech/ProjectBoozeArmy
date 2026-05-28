class_name EnemyDeadState
extends State

@export var parent: EnemyBase


func enter():
	print("Enemigo eliminado")
	parent.queue_free()
