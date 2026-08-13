class_name FloorTreadmill
extends MeshInstance3D

# Piso "cinta de correr": la malla sigue al jugador en X/Z para que siempre
# haya suelo debajo. La textura no se desliza porque el shader del material
# pinta en coordenadas de mundo (ver floor_grid.gdshader).
# La colisión es un WorldBoundaryShape3D (plano infinito), así que moverse
# horizontalmente no afecta a la física.


# La referencia al jugador se cachea: buscarla por grupo en cada frame de
# física es un coste innecesario, y el jugador no cambia durante la partida
var _player: Node3D


func _physics_process(_delta: float) -> void:
	if not is_instance_valid(_player):
		_player = get_tree().get_first_node_in_group("player") as Node3D
		if not is_instance_valid(_player):
			return
	global_position.x = _player.global_position.x
	global_position.z = _player.global_position.z
