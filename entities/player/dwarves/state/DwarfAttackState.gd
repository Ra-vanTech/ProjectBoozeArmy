class_name DwarfAttackState
extends State

@onready var dwarf: EnanoBase = owner as EnanoBase

var current_target: Node3D = null
var current_cooldown: float = 0.0
# Periodo del ciclo actual. Se recalcula al golpear y no en cada frame:
# obtener_cooldown_final() consulta dos gestores por búsqueda de grupo, y
# hacerlo 60 veces por segundo y por enano era de lo más caro del juego. Los
# cambios de ebriedad o mejoras entran en el siguiente golpe, no a mitad de uno.
var _cooldown_objetivo: float = 1.0

# Fase inicial aleatoria para desincronizar a los enanos entre sí sin
# acortar el cooldown real (antes se restaba tiempo en cada golpe)
func enter() -> void:
	_cooldown_objetivo = dwarf.obtener_cooldown_final()
	current_cooldown = randf_range(0.0, _cooldown_objetivo)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func tick(delta: float) -> void:
	# condicion de enemigos lejos -> vuelvo a idle
	if dwarf.enemies_in_range.is_empty():
		current_target = null
		state_machine.change_state("DwarfIdleState")
		return
	# actualizar objetivo (el mas cercano)
	_update_target()

	# gestionamos tiempo de ataque
	current_cooldown += delta
	if current_cooldown >= _cooldown_objetivo and is_instance_valid(current_target):
		dwarf._attack(current_target)
		# Cooldown completo hasta el siguiente golpe (la desincronización ya se
		# aplicó en enter(), aquí se respeta el periodo real)
		current_cooldown = 0.0
		_cooldown_objetivo = dwarf.obtener_cooldown_final()


# Purga las referencias muertas y busca el objetivo más cercano en una sola
# pasada. Antes se hacía con .filter() y una lambda, que reservaba un array y
# creaba un Callable nuevos en cada frame y por cada enano.
func _update_target() -> void:
	var lista: Array[Node3D] = dwarf.enemies_in_range
	var closest_enemy: Node3D = null
	var shortest_distance: float = INF

	for i in range(lista.size() - 1, -1, -1):
		var enemy: Node3D = lista[i]
		if not is_instance_valid(enemy):
			lista.remove_at(i)
			continue
		var dist: float = dwarf.global_position.distance_squared_to(enemy.global_position)
		if dist < shortest_distance:
			shortest_distance = dist
			closest_enemy = enemy

	current_target = closest_enemy
