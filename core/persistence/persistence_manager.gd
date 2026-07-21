# Llamado Store en el cargado automático
extends Node

enum DATA {
	GOLD,

	# Cosas del gestor de mejoras
	DMG_MAX_LVL,
	ATK_SPEED_MAX_LVL,
	DWARF_LIMIT_MAX_LVL,
	DRUNKENNESS_MAX_LVL,
	ENEMY_HP_REDUCTION_MAX_LVL,
	MAX_DRUNKENNESS_MAX_LVL,
	XP_BONUS_MAX_LVL,
	COINS_BONUS_MAX_LVL,

	# Cosas del jugador (o los enanos)
	STARTING_DWARVES,
	MAX_LVL,
	BASE_ATK,
	BASE_ATK_SP,
	BASE_SPD,
	MAX_DRUNKENNESS,
	XP_BONUS,
	COINS_BONUS,
}

const DATA_PATH: String = "user://data.json"
const STARTING_VAL: Dictionary = {
	DATA.GOLD: 0,
	#
	# Mejoras por partida
	DATA.DMG_MAX_LVL: 5,
	DATA.ATK_SPEED_MAX_LVL: 5,
	DATA.DWARF_LIMIT_MAX_LVL: 5,
	DATA.DRUNKENNESS_MAX_LVL: 1,
	DATA.ENEMY_HP_REDUCTION_MAX_LVL: 5,
	DATA.MAX_DRUNKENNESS_MAX_LVL: 5,
	DATA.XP_BONUS_MAX_LVL: 5,
	DATA.COINS_BONUS_MAX_LVL: 5,
	#
	# Mejoras permanentes
	DATA.MAX_LVL: 10,
	DATA.STARTING_DWARVES: 3,
	DATA.BASE_ATK: 0,
	DATA.BASE_ATK_SP: 0,
	DATA.BASE_SPD: 0,
	DATA.MAX_DRUNKENNESS: 0,
	DATA.XP_BONUS: 0,
	DATA.COINS_BONUS: 0,
}

var save: Dictionary = {
	DATA.GOLD: STARTING_VAL[DATA.GOLD],
	#
	DATA.DMG_MAX_LVL: STARTING_VAL[DATA.DMG_MAX_LVL],
	DATA.ATK_SPEED_MAX_LVL: STARTING_VAL[DATA.ATK_SPEED_MAX_LVL],
	DATA.DWARF_LIMIT_MAX_LVL: STARTING_VAL[DATA.DWARF_LIMIT_MAX_LVL],
	DATA.DRUNKENNESS_MAX_LVL: STARTING_VAL[DATA.DRUNKENNESS_MAX_LVL],
	DATA.ENEMY_HP_REDUCTION_MAX_LVL: STARTING_VAL[DATA.ENEMY_HP_REDUCTION_MAX_LVL],
	DATA.MAX_DRUNKENNESS_MAX_LVL: STARTING_VAL[DATA.MAX_DRUNKENNESS_MAX_LVL],
	DATA.XP_BONUS_MAX_LVL: STARTING_VAL[DATA.XP_BONUS_MAX_LVL],
	DATA.COINS_BONUS_MAX_LVL: STARTING_VAL[DATA.COINS_BONUS_MAX_LVL],
	#
	DATA.MAX_LVL: STARTING_VAL[DATA.MAX_LVL],
	DATA.STARTING_DWARVES: STARTING_VAL[DATA.STARTING_DWARVES],
	DATA.BASE_ATK: STARTING_VAL[DATA.BASE_ATK],
	DATA.BASE_ATK_SP: STARTING_VAL[DATA.BASE_ATK_SP],
	DATA.BASE_SPD: STARTING_VAL[DATA.BASE_SPD],
	DATA.MAX_DRUNKENNESS: STARTING_VAL[DATA.MAX_DRUNKENNESS],
	DATA.XP_BONUS: STARTING_VAL[DATA.XP_BONUS],
	DATA.COINS_BONUS: STARTING_VAL[DATA.COINS_BONUS],
}


func _ready() -> void:
	load_data()


func save_data() -> void:
	print(save, " (save start)")
	# Lo considero bueno por que si no se cargan los datos al cargar los que estaban en
	# el archivo y no en save o tenian valores distintos se eliminan/sobreescriben
	# NOTA: los sigue sobreescribiendo, alch no entiendo
	# NOTA: no es buena idea por que tambien sobreescribe los datos actuales, por lo que no se puede guardar nada
	# load_data()
	var file: FileAccess = FileAccess.open(DATA_PATH, FileAccess.WRITE)
	file.store_var(save)
	file.close()
	print(save, " (save end)")


func load_data() -> void:
	if FileAccess.file_exists(DATA_PATH):
		var file: FileAccess = FileAccess.open(DATA_PATH, FileAccess.READ)
		var extracted_data: Dictionary = file.get_var()
		print(extracted_data, " (extracted)")
		for i in extracted_data: # Así no borra datos que aún no se hayan guardado al hacer la carga de datos
			if save.has(i):
				save[i] = extracted_data[i]
		file.close()
