class_name DwarfSystem
extends Node3D

signal enano_eliminado(enanos_id: int)
signal ejercito_derrotado

#Precargar la escena del enano para instanciarla en tiempo de ejecucion.
const ENANO_SCENE: PackedScene = preload("res://entities/player/dwarves/scenes/enano_guerrero.tscn")

#configuracion (enanos iniciales, maximo de enanos y radio de formacion)
@export var initial_dwarves: int = 3
@export var max_dwarves: int = 10
@export var formation_radius: float = 2.5

var dwarves: Array[Node3D] = []

#Referencia de HealtComponent del jugador para conexion provisional
@onready var _player_health: HealthComponent = %HealthComponent


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in range(initial_dwarves):
		agregar_enano()

	#Conectar la señal de daño a los enanos
	if is_instance_valid(_player_health):
		_player_health.has_died.connect(eliminar_enano)
	else:
		push_error("[DwarfSystem] No se encontró HealthComponent en el jugador")


func agregar_enano() -> void:
	if dwarves.size() >= max_dwarves:
		return
	var enano: EnanoBase = ENANO_SCENE.instantiate()
	add_child(enano)
	dwarves.append(enano)
	actualizar_formacion()


func eliminar_enano() -> void:
	# Elimina el último enano del array (llamar cuando el jugador recibe daño)
	if dwarves.size() == 0:
		return
	var enano_id: int = dwarves.size() - 1
	var enano: Node3D = dwarves.pop_back()
	enano.queue_free()
	enano_eliminado.emit(enano_id)

	actualizar_formacion()
	print("[DEBUG] Enano eliminado id=%d. Restantes: %d" % [enano_id, dwarves.size()])

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


func _sin_enanos() -> void:
	print("[DwarfSystem] Todos los enanos eliminados — Game Over")
	ejercito_derrotado.emit()
