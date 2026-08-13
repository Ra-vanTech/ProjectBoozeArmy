class_name UpgradeScreenOverlay
extends CanvasLayer

# Pantalla de elección de mejora al subir de nivel.
#
# Si se suben varios niveles con una sola recogida de XP, XPManager emite
# level_up una vez por nivel: cada uno se encola y se resuelve con su propia
# elección, uno detrás de otro. Antes se perdían todos menos el primero.
#
# La pantalla se mueve por eventos (señal de subida y pulsación de botón),
# no en _process: no hay nada que recalcular cada frame.

# Niveles alcanzados pendientes de elegir mejora, en orden
var _niveles_pendientes: Array[int] = []
var _opciones_actuales: Array = []

@onready var game_manager: GameManager = get_tree().get_first_node_in_group("game_manager")
@onready var _level_label: Label = $CenterContainer/PanelContainer/VBoxContainer/LevelLabel
@onready var _button_1: Button = $CenterContainer/PanelContainer/VBoxContainer/HBoxContainer/Option1
@onready var _button_2: Button = $CenterContainer/PanelContainer/VBoxContainer/HBoxContainer/Option2
@onready var _button_3: Button = $CenterContainer/PanelContainer/VBoxContainer/HBoxContainer/Option3
@onready var botones: Array[Button] = [_button_1, _button_2, _button_3]


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	visible = false

	if is_instance_valid(game_manager):
		game_manager.xp_manager.level_up.connect(_on_level_up)
	else:
		push_error("[UpgradeScreen] No se encontró GameManager en la escena")


func _on_level_up(new_level: int) -> void:
	_niveles_pendientes.append(new_level)
	# Si ya hay una elección en curso, este nivel espera su turno
	if not visible:
		_mostrar_siguiente()


# Pinta las opciones del primer nivel pendiente. Si no quedan niveles (o no
# quedan mejoras que ofrecer) cierra la pantalla y reanuda la partida.
func _mostrar_siguiente() -> void:
	if _niveles_pendientes.is_empty():
		_cerrar()
		return

	_opciones_actuales = game_manager.upgrade_manager.get_upgrade_list()
	if _opciones_actuales.is_empty():
		# Todas las mejoras al máximo: no hay nada que elegir, no se bloquea
		# al jugador con una pantalla vacía
		_niveles_pendientes.clear()
		_cerrar()
		return

	_level_label.text = "Nivel " + str(_niveles_pendientes[0]) + "!"

	# Solo se muestran tantos botones como opciones haya: dejarlos visibles con
	# el texto de la ronda anterior permitía pulsar una opción inexistente
	for i in range(botones.size()):
		var boton: Button = botones[i]
		boton.visible = i < _opciones_actuales.size()
		if not boton.visible:
			continue
		var tipo = _opciones_actuales[i]
		var data: Dictionary = game_manager.upgrade_manager.upgrade_descriptions[tipo]
		var lvl: String = game_manager.upgrade_manager.get_level(tipo)
		boton.text = data["name"] + "\n" + lvl + "\n" + data["desc"]

	visible = true
	get_tree().paused = true


func _cerrar() -> void:
	visible = false
	get_tree().paused = false


func _seleccionar(index: int) -> void:
	# Guarda contra pulsaciones fuera de rango (botón de una ronda con más
	# opciones, o doble pulsación mientras se cierra la pantalla)
	if index < 0 or index >= _opciones_actuales.size():
		return
	game_manager.upgrade_manager.apply_upgrade(_opciones_actuales[index])
	_opciones_actuales = []
	if not _niveles_pendientes.is_empty():
		_niveles_pendientes.pop_front()
	# Encadena el siguiente nivel pendiente, si lo hay
	_mostrar_siguiente()


func _on_option_1_pressed() -> void:
	_seleccionar(0)


func _on_option_2_pressed() -> void:
	_seleccionar(1)


func _on_option_3_pressed() -> void:
	_seleccionar(2)
