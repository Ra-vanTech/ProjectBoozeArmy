class_name DwarfSystem
extends Node3D

signal enano_eliminado(enanos_id: int)

#Precargar la escena del enano para instanciarla en tiempo de ejecucion.
const ENANO_SCENE: PackedScene = preload("res://entities/player/dwarves/scenes/enano_base.tscn")

#configuracion (enanos iniciales, maximo de enanos y radio de formacion)
@export var initial_dwarves: int = 3
@export var max_dwarves: int = 10
@export var formation_radius: float = 2.5

var dwarves: Array[Node3D] = []

#Referencia de HealtComponent del jugador para conexion provisional
@onready var _player_health: HealthComponent = get_node("../HealthComponent")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in range(initial_dwarves):
		agregar_enano()

	#Conexion provisional: cada vez que el jugador recibe daño pierde un enano (aun se implementara la colision player-enemigo)
	if is_instance_valid(_player_health):
		_player_health.received_damage.connect(eliminar_enano)
		print("[DEBUG] DwarfSystem conectado al daño del jugador")
	else:
		push_warning("[DwarfSystem] No se encontró HealthComponent en el jugador")


#Debug keys(para testing)
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_Q:
				print("[DEBUG KEY] Q presionada → agregar_enano()")
				agregar_enano()
			KEY_E:
				print("[DEBUG KEY] E presionada → eliminar_enano()")
				eliminar_enano()


func agregar_enano() -> void:
	if dwarves.size() >= max_dwarves:
		return
	var enano: EnanoBase = ENANO_SCENE.instantiate()
	add_child(enano)
	dwarves.append(enano)
	actualizar_formacion()
	print("[DEBUG] Enano añadido. Total: %d" % dwarves.size())


func eliminar_enano() -> void:
	# Elimina el último enano del array (llamar cuando el jugador recibe daño)
	if dwarves.size() == 0:
		return
	var enano_id: int = dwarves.size() - 1
	var enano: Node3D = dwarves.pop_back()
	enano.queue_free()
	enano_eliminado.emit(enano_id)

	if is_instance_valid(_player_health):
		_player_health.health = _player_health.health

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
	if is_instance_valid(_player_health):
		_player_health.has_died.emit()
