class_name AutoAimComponent
extends Node

@export var desired_target: Node3D

var direction3D: Vector3
var direction: Vector2

@onready var spawners = get_tree().get_nodes_in_group("spawners")


func tick() -> void:
	pass


func find_target() -> void:
	pass
