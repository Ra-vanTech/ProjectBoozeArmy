class_name SeekingComponent
extends Node3D

var direction: Vector2 = Vector2.ZERO
var direction3D: Vector3 # solamente se usa para la conversión de la dirección de Vector3 a Vector2

@onready var player: Player = get_tree().get_first_node_in_group("player")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func tick() -> void:
	direction3D = (player.position - global_position).normalized()
	direction = Vector2(direction3D.x, direction3D.z).normalized()
