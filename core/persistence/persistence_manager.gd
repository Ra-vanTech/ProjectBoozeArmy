extends Node

const DATA_PATH: String = "user://data.json"

var data: Dictionary = {
	"gold": 0,
	"max_level": 10,
}


func _ready() -> void:
	load_data()


func save_data() -> void:
	print(data, " (opening)")
	# Lo considero bueno por que si no se cargan los datos al cargar los que estaban en
	# el archivo y no en data o tenian valores distintos se eliminan/sobreescriben
	# NOTA: los sigue sobreescribiendo, alch no entiendo
	load_data()
	var file: FileAccess = FileAccess.open(DATA_PATH, FileAccess.WRITE)
	file.store_var(data)
	file.close()
	print(data, " (closure)")


func load_data() -> void:
	if FileAccess.file_exists(DATA_PATH):
		var file: FileAccess = FileAccess.open(DATA_PATH, FileAccess.READ)
		var extracted_data: Dictionary = file.get_var()
		print(extracted_data, " (extracted)")
		for i in extracted_data: # Así no borra datos que aún no se hayan guardado al hacer la carga de datos
			if data.has(i):
				data[i] = extracted_data[i]
				print(data, " (loop)")
		file.close()
