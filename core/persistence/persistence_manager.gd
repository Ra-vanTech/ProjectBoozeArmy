extends Node

const DATA_PATH: String = "user://save_test.json"

var data: Dictionary = {
	"test_value": 67,
}


func _ready() -> void:
	load_data()
	data["lol"] = true
	save_data()


func save_data() -> void:
	var file: FileAccess = FileAccess.open(DATA_PATH, FileAccess.WRITE)
	file.store_var(data)
	file.close()


func load_data() -> void:
	if FileAccess.file_exists(DATA_PATH):
		var file: FileAccess = FileAccess.open(DATA_PATH, FileAccess.READ)
		var extracted_data: Dictionary = file.get_var()
		for i in extracted_data: # Así no borra datos que aún no se hayan guardado al hacer la carga de datos
			if data.has(i):
				data[i] = extracted_data[i]
		file.close()
