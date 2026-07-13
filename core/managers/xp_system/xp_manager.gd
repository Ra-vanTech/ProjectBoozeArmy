class_name XPManager
extends Node

signal xp_gained(current_xp: int, required_xp: int)
signal max_level_reached
signal level_up(new_level: int)

@export_range(1, 1000) var MAX_LEVEL = 10
@export_range(10, 1000) var starting_xp_requirement = 10

var max_level_signal_emitted := false
var current_xp: int:
	set(input):
		if current_level >= MAX_LEVEL:
			if not max_level_signal_emitted: # Evita que se reenvie la señal cada vez que se obtiene experiencia
				max_level_reached.emit()
				max_level_signal_emitted = true
			return
		current_xp = input

		var required: int = _xp_for_level(current_level)

		# Capturamos XP ganada en el HUD
		# xp_gained.emit(current_xp, required) # no veo por que se emitía 2 veces pero bueno

		#Verificar si se pasó uno o varios niveles con una sola recogida
		while current_xp >= required and current_level < MAX_LEVEL:
			current_xp -= required
			current_level += 1
			level_up.emit(current_level)
			if current_level >= MAX_LEVEL: # Si no se hace esto no se actualiza al momento
				max_level_reached.emit()
				max_level_signal_emitted = true
			required = _xp_for_level(current_level)

		# Actualizamos XP en HUD de nuevo
		if current_level < MAX_LEVEL:
			xp_gained.emit(current_xp, _xp_for_level(current_level))
var current_level: int = 1


#formula para la experiencia
func _xp_for_level(level: int) -> int:
	return roundi(starting_xp_requirement * pow(1.2, level - 1))
