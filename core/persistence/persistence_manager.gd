extends Node

enum DATA {
	GOLD,
	MAX_LVL,

	# Cosas del gestor de mejoras
	# No está el de enanos pq en mi opinión debería de ser ilimitada
	DMG_MAX_LVL,
	ATK_SPEED_MAX_LVL,
	DWARF_LIMIT_MAX_LVL,
	DRUNKENNESS_MAX_LVL,
	ENEMY_HP_REDUCTION_MAX_LVL,
}

const DATA_PATH: String = "user://data.json"

var save: Dictionary = {
	DATA.GOLD: 0,
	DATA.MAX_LVL: 10,
	DATA.DMG_MAX_LVL: 10,
	DATA.ATK_SPEED_MAX_LVL: 10,
	DATA.DWARF_LIMIT_MAX_LVL: 5,
	DATA.DRUNKENNESS_MAX_LVL: 1,
	DATA.ENEMY_HP_REDUCTION_MAX_LVL: 5,
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
				print(save, " (loop)")
		file.close()
