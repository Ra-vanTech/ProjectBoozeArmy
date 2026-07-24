# Llamado Store en el cargado automático
extends Node

signal save_completed(success: bool)
signal load_completed(success: bool)


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
const DATA_PATH_TMP: String = DATA_PATH + ".tmp"
const SAVE_VERSION: int = 1
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


# Convierte un Dictionary con llaves DATA (enum/int) a uno con llaves string,
# listo para pasar a JSON.stringify(). Uso: _dict_to_json_ready(save)
func _dict_to_json(source: Dictionary) -> Dictionary:
	var result: Dictionary = {}
	for data_key in source:
		var key_name: String = DATA.keys()[data_key]
		result[key_name] = source[data_key]
	return result


# Convierte de vuelta un Dictionary con llaves string (recién parseado de JSON)
#a uno con llaves DATA (enum/int). Ignora y reporta claves que ya no existan		

func json_to_dict(source: Dictionary) -> Dictionary:
	var result: Dictionary = {}
	for key_name in source:
		if DATA.keys().has(key_name):
			var data_key: int = DATA[key_name]
			result[data_key] = source[key_name]
		else:
			push_warning("[SaveSystem] Clave desconocida en el save, ignorada: " + str(key_name))
	return result


func save_data() -> void:
	print(save, " (save start)")
	var payload: Dictionary = {
		"version": SAVE_VERSION,
		"data": _dict_to_json(save)
	}
	var json_text: String = JSON.stringify(payload, "\t")

	#se escribe en un archivo temporal antes de guardar completamente 
	var file: FileAccess = FileAccess.open(DATA_PATH_TMP, FileAccess.WRITE)
	if file == null:
		push_error("[SaveSystem] No se pudo abrir el archivo temporal: " + DATA_PATH_TMP + ", error: " + str(FileAccess.get_open_error()))
		save_completed.emit(false)
		return

	file.store_string(json_text)
	file.close()

	#se hace una copia del archivo temporal para guardarlo permanentemente SOLO si el temporal termino bien 
	var rename_error: int = DirAccess.rename_absolute(DATA_PATH_TMP, DATA_PATH)
	if rename_error != OK:
		push_error("[SaveSystem] No se pudo renombrar el archivo temporal: " + DATA_PATH_TMP + ", error: " + str(rename_error))
		save_completed.emit(false)
		return

	print(save, " (save end)")
	save_completed.emit(true)


func load_data() -> void:
	if not FileAccess.file_exists(DATA_PATH):
		return
	
	var file: FileAccess = FileAccess.open(DATA_PATH, FileAccess.READ)
	var json_text: String = file.get_as_text()
	file.close()

	var parsed: Variant = JSON.parse_string(json_text)
	if parsed == null or typeof(parsed) != TYPE_DICTIONARY:
		push_error("[SaveSystem] el archivo de guardado esta corrupto o tine un formato inesperado")
		load_completed.emit(false)
		return
		
	var payload: Dictionary = parsed
	if not payload.has("version") or not payload.has("data"):
		push_error("[SaveSystem] El archivo de guardado no tiene el formato esperado (faltan 'version' o 'data'). Se usarán los valores por defecto.")
		load_completed.emit(false)
		return
	

	var extracted_data: Dictionary = json_to_dict(payload["data"])
	for data_key in extracted_data: # Así no borra datos que aún no se hayan guardado al hacer la carga de datos
		if save.has(data_key):
				save[data_key] = extracted_data[data_key]

	load_completed.emit(true)
