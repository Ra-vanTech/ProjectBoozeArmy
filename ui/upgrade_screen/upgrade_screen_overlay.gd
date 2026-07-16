class_name UpgradeScreenOverlay
extends CanvasLayer

var _opciones_actuales: Array = []

@onready var game_manager: GameManager = get_tree().get_first_node_in_group("game_manager")
@onready var _level_label: Label = $CenterContainer/PanelContainer/VBoxContainer/LevelLabel
@onready var _button_1: Button = $CenterContainer/PanelContainer/VBoxContainer/HBoxContainer/Option1
@onready var _button_2: Button = $CenterContainer/PanelContainer/VBoxContainer/HBoxContainer/Option2
@onready var _button_3: Button = $CenterContainer/PanelContainer/VBoxContainer/HBoxContainer/Option3


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	visible = false

	game_manager.xp_manager.level_up.connect(_on_level_up)


func _on_level_up(new_level: int) -> void:
	_opciones_actuales = game_manager.upgrade_manager.get_upgrade_list()

	_level_label.text = "Nivel " + str(new_level) + "!"
	var botones: Array = [_button_1, _button_2, _button_3]
	for i in range(len(_opciones_actuales)):
		var tipo = _opciones_actuales[i]
		var data: Dictionary = game_manager.upgrade_manager.upgrade_descriptions[tipo]
		var lvl: String = game_manager.upgrade_manager.get_level(tipo)
		botones[i].text = data["name"] + "\n" + lvl + "\n" + data["desc"]

	visible = true
	get_tree().paused = true


func _seleccionar(index: int) -> void:
	game_manager.upgrade_manager.apply_upgrade(_opciones_actuales[index])
	visible = false
	get_tree().paused = false


func _on_option_1_pressed() -> void:
	_seleccionar(0)


func _on_option_2_pressed() -> void:
	_seleccionar(1)


func _on_option_3_pressed() -> void:
	_seleccionar(2)
