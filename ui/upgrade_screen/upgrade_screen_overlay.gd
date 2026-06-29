class_name UpgradeScreenOverlay
extends CanvasLayer

const UPGRADE_DATA: Dictionary = {
	UpgradeManager.UpgradeType.DAMAGE: { "nombre": "+20% Daño", "desc": "Los enanos atacan con más fuerza." },
	UpgradeManager.UpgradeType.ATTACK_SPEED: { "nombre": "+15% Vel. Ataque", "desc": "Los enanos atacan más rápido." },
	UpgradeManager.UpgradeType.ADD_DWARF: { "nombre": "+1 Enano", "desc": "Un nuevo enano se une al ejército." },
	UpgradeManager.UpgradeType.SOBRIETY_REGEN: { "nombre": "+1 Ebriedad/s", "desc": "La ebriedad cae más lento." },
	UpgradeManager.UpgradeType.ENEMY_HP: { "nombre": "-10% HP Enemigos", "desc": "Los enemigos spawnean con menos vida." },
}

@export var xp_system: XPSystem
@export var upgrades_manager: UpgradeManager

var _opciones_actuales: Array = []

@onready var _level_label: Label = $CenterContainer/PanelContainer/VBoxContainer/LevelLabel
@onready var _button_1: Button = $CenterContainer/PanelContainer/VBoxContainer/HBoxContainer/Button1
@onready var _button_2: Button = $CenterContainer/PanelContainer/VBoxContainer/HBoxContainer/Button2
@onready var _button_3: Button = $CenterContainer/PanelContainer/VBoxContainer/HBoxContainer/Button3


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	visible = false

	if is_instance_valid(xp_system):
		xp_system.level_up.connect(_on_level_up)


func _on_level_up(new_level: int) -> void:
	var todos: Array = UpgradeManager.UpgradeType.values()
	todos.shuffle()
	_opciones_actuales = todos.slice(0, 3)

	_level_label.text = "Nivel " + str(new_level) + "!"
	var botones: Array = [_button_1, _button_2, _button_3]
	for i in range(3):
		var tipo = _opciones_actuales[i]
		var data: Dictionary = UPGRADE_DATA[tipo]
		botones[i].text = data["nombre"] + "\n" + data["desc"]

	get_tree().paused = true
	visible = true
