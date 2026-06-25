class_name DwarfAttackState
extends State

@onready var dwarf: EnanoBase = owner as EnanoBase

var current_target: Node3D = null
var current_cooldown: float = 0.0

# Forzamos el cooldwn al maximo para que el golpe sea inmediato 
func enter() -> void:
	current_cooldown = dwarf.obtener_cooldown_final()


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
	if current_cooldown >= dwarf.obtener_cooldown_final() and is_instance_valid(current_target):
		dwarf._attack(current_target)
		#cambio: hacemos una variacion de tiempo entre los enanos para que ataquen en distinto tiempo 
		current_cooldown = randf_range(0.0, 0.4)


func _update_target() -> void:
	# limpiamos referencias nulas 
	dwarf.enemies_in_range = dwarf.enemies_in_range.filter(func(e): return is_instance_valid(e))
	if dwarf.enemies_in_range.is_empty():
		current_target = null
		return
	
	var closest_enemy: Node3D = null
	var shortest_distance: float = INF

	# Iteramos para encontrar enemigos cercanos 
	for enemy in dwarf.enemies_in_range:
		var dist: float = dwarf.global_position.distance_squared_to(enemy.global_position)
		if dist < shortest_distance:
			shortest_distance = dist
			closest_enemy = enemy
		
	current_target = closest_enemy
