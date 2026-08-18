class_name WorldWrap
extends Node

# Mundo toroidal: cada nodo del grupo "world_wrapped" (casas, drops, etc.)
# se muestra en su "copia envuelta" más cercana al jugador. El mundo se
# repite cada world_size unidades: si caminas world_size en cualquier
# dirección, terminas donde empezaste. No se teletransporta al jugador ni
# a la cámara, por lo que no hay costuras ni saltos visuales.
#
# La posición canónica de cada nodo se guarda en metadata la primera vez
# que se ve (muere con el nodo, sin fugas). El reposicionamiento solo
# ocurre cuando cambia de celda, así que el costo por frame es ínfimo.

@export var world_size: float = 150.0
## Cada cuántos frames de física se revisa el envoltorio. Los nodos envueltos
## son decorados lejanos (casas, drops): reposicionarlos 15 veces por segundo
## es imperceptible y evita recorrer el grupo entero en cada frame.
const FRAMES_ENTRE_REVISIONES: int = 4

var _player: Node3D
var _frames: int = 0


func _physics_process(_delta: float) -> void:
	_frames += 1
	if _frames < FRAMES_ENTRE_REVISIONES:
		return
	_frames = 0

	if not is_instance_valid(_player):
		_player = Services.player
		if not is_instance_valid(_player):
			return
	var p: Vector3 = _player.global_position

	for node in get_tree().get_nodes_in_group("world_wrapped"):
		var n3d := node as Node3D
		if n3d == null or not n3d.is_inside_tree():
			continue
		if not n3d.has_meta("wrap_canonical"):
			n3d.set_meta("wrap_canonical", n3d.global_position)
		var c: Vector3 = n3d.get_meta("wrap_canonical")
		var target := Vector3(
			c.x + roundf((p.x - c.x) / world_size) * world_size,
			c.y,
			c.z + roundf((p.z - c.z) / world_size) * world_size
		)
		if n3d.global_position.distance_squared_to(target) > 0.01:
			n3d.global_position = target
