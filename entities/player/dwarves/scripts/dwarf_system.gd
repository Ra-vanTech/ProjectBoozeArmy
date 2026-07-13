class_name DwarfSystem
extends Node3D

signal enano_eliminado(enanos_id: int)
signal ejercito_derrotado

#configuracion (enanos iniciales, maximo de enanos y radio de formacion)
@export var initial_dwarves: int = 3
@export var max_dwarves: int = 10
@export var formation_radius: float = 2.5
#para agregar un nuevo tipo de enano, sin tocar el script
@export var enano_scenes: Array[PackedScene] = []

var dwarves: Array[Node3D] = []


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in range(initial_dwarves):
		agregar_enano()

	var upgrade_manager: UpgradeManager = get_tree().get_first_node_in_group("upgrade_manager")
	if is_instance_valid(upgrade_manager):
		upgrade_manager.upgrade_applied.connect(_on_upgrade_applied)
	else:
		push_error("[DwarfSystem] No se encontró UpgradeManager en la escena")


func agregar_enano() -> void:
	if dwarves.size() >= max_dwarves:
		return
	var escena: PackedScene = enano_scenes[randi() % enano_scenes.size()]
	var enano: EnanoBase = escena.instantiate()
	add_child(enano)
	dwarves.append(enano)
	actualizar_formacion()
	#print para probar upgrade +1 enano
	# print("[DwarfSystem] Enano agregado: ", enano.get_script().get_global_name(), " | Total: ", dwarves.size())


func eliminar_enano() -> void:
	# Elimina el último enano del array (llamar cuando el jugador recibe daño)
	if dwarves.size() == 0:
		return
	var enano_id: int = dwarves.size() - 1
	var enano: Node3D = dwarves.pop_back()
	enano.queue_free()
	enano_eliminado.emit(enano_id)

	actualizar_formacion()

	if dwarves.size() == 0:
		_sin_enanos()


func actualizar_formacion() -> void:
	var count: int = dwarves.size()
	if count == 0:
		return

	#Dividir 360° (TAU = 2*PI) entre la cantidad de enanos vivos
	var angle_step: float = TAU / float(count)
	for i in range(count):
		var angle: float = float(i) * angle_step
		#posicion en el plano X/Z
		var x: float = cos(angle) * formation_radius
		var z: float = sin(angle) * formation_radius
		dwarves[i].position = Vector3(x, 0, z)


func _on_upgrade_applied(type: UpgradeManager.UpgradeType) -> void:
	if type == UpgradeManager.UpgradeType.ADD_DWARF:
		agregar_enano()


func _sin_enanos() -> void:
	# print("[DwarfSystem] Todos los enanos eliminados — Game Over")
	ejercito_derrotado.emit()
