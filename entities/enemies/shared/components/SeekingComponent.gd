# Si tuviese que darle un nombre, sería seguimiento torpe
# esto debido a que solamente proporciona la dirección del jugador y no toma en cuenta obstáculos
class_name SeekingComponent
extends Node3D

var direction: Vector2 = Vector2.ZERO
var direction3D: Vector3 # solamente se usa para la conversión de la dirección de Vector3 a Vector2
var distance_to_player: float

var player: Player = null

# Called every frame. 'delta' is the elapsed time since the previous frame.
func tick() -> void:
	if not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player") as Player
	
	if not is_instance_valid(player):
		direction = Vector2.ZERO
		return

	var diff: Vector3 = player.global_position - global_position
	if diff.length_squared() < 0.0001:
		return
	direction3D = diff.normalized()
	direction = Vector2(direction3D.x, direction3D.z).normalized()
	distance_to_player = global_position.distance_to(player.global_position)
