extends SceneTree
# Carga todas las escenas y recursos del proyecto y reporta los que fallan.
# Detecta rutas res:// rotas, que audit_uids.py no ve (ese solo mira uid://).
# Uso: godot --headless --script tools/verificar_escenas.gd

func _init() -> void:
	var rutas: Array[String] = []
	_recorrer("res://", rutas)
	rutas.sort()
	var fallos := 0
	for r in rutas:
		var res = ResourceLoader.load(r)
		if res == null:
			print("FALLA  ", r)
			fallos += 1
	print("VERIFICADAS %d  FALLOS %d" % [rutas.size(), fallos])
	quit(1 if fallos > 0 else 0)

func _recorrer(dir_ruta: String, salida: Array[String]) -> void:
	var d := DirAccess.open(dir_ruta)
	if d == null:
		return
	d.list_dir_begin()
	var nombre := d.get_next()
	while nombre != "":
		if nombre.begins_with("."):
			nombre = d.get_next()
			continue
		var completa := dir_ruta.path_join(nombre) if dir_ruta != "res://" else "res://" + nombre
		if d.current_is_dir():
			_recorrer(completa, salida)
		elif nombre.get_extension() in ["tscn", "tres"]:
			salida.append(completa)
		nombre = d.get_next()
	d.list_dir_end()
