class_name DwarfSystem
extends Node3D

signal enano_eliminado(enanos_id: int)
signal ejercito_derrotado

@export var max_dwarves: int = 10
@export var formation_radius: float = 2.5
#para agregar un nuevo tipo de enano, sin tocar el script
@export var enano_scenes: Array[PackedScene] = []

# Movimiento de enjambre: los enanos ya no ocupan puntos fijos, se agrupan
# solos hacia el centro (el jugador) empujándose entre sí, como en Vampire
# Survivors. Todo se calcula en coordenadas locales del contenedor, así que
# el grupo sigue al jugador automáticamente.
@export_group("Enjambre")
## Qué tan fuerte tira cada enano hacia el jugador
@export var cohesion_strength: float = 5.0
## Distancia mínima que intentan mantener entre sí
@export var separation_distance: float = 1.4
@export var separation_strength: float = 14.0
## Radio alrededor del jugador que dejan libre
@export var player_clearance: float = 1.2
## Deriva aleatoria para que el grupo se sienta vivo
@export var wander_strength: float = 2.0
@export var max_speed: float = 4.0

var dwarves: Array[Node3D] = []

#configuracion (enanos iniciales, maximo de enanos y radio de formacion)
@onready var initial_dwarves: int = Store.save[Store.DATA.STARTING_DWARVES]


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
	if enano_scenes.is_empty():
		push_error("[DwarfSystem] No hay escenas de enano asignadas en enano_scenes")
		return
	var escena: PackedScene = enano_scenes[randi() % enano_scenes.size()]
	var enano: EnanoBase = escena.instantiate()
	add_child(enano)
	# Aparece en un punto aleatorio del anillo; el enjambre lo acomoda solo
	var angle: float = randf() * TAU
	enano.position = Vector3(cos(angle), 0, sin(angle)) * formation_radius
	dwarves.append(enano)
	#print para probar upgrade +1 enano
	# print("[DwarfSystem] Enano agregado: ", enano.get_script().get_global_name(), " | Total: ", dwarves.size())


func eliminar_enano() -> void:
	# Elimina el último enano del array (llamar cuando el jugador recibe daño)
	if dwarves.size() == 0:
		return
	var enano_id: int = dwarves.size() - 1
	var enano: Node3D = dwarves.pop_back()
	# Feedback visual: sin esto los enanos desaparecían en silencio y no se
	# entendía cuándo el jugador recibía daño
	CombatVFX.hit_particles(self, enano.global_position, Color(0.9, 0.2, 0.2))
	CombatVFX.floating_text(self, enano.global_position, "-1 enano", Color(1, 0.3, 0.3))
	enano.queue_free()
	enano_eliminado.emit(enano_id)

	if dwarves.size() == 0:
		_sin_enanos()


func _physics_process(delta: float) -> void:
	var count: int = dwarves.size()
	for i in range(count):
		var enano: EnanoBase = dwarves[i]
		var pos: Vector3 = enano.position
		var accel: Vector3 = Vector3.ZERO

		# Cohesión: tirar hacia el jugador (origen local del contenedor)
		accel += Vector3(-pos.x, 0, -pos.z) * cohesion_strength

		# Separación entre enanos (empuje inverso a la distancia)
		for j in range(count):
			if i == j:
				continue
			var diff: Vector3 = pos - dwarves[j].position
			diff.y = 0.0
			var dist: float = diff.length()
			if dist < separation_distance and dist > 0.001:
				accel += (diff / dist) * separation_strength * (1.0 - dist / separation_distance)

		# No pisar al jugador
		var dist_center: float = Vector2(pos.x, pos.z).length()
		if dist_center < player_clearance:
			accel += Vector3(pos.x, 0, pos.z).normalized() * separation_strength

		# Deriva aleatoria suave
		accel += Vector3(randf_range(-1.0, 1.0), 0, randf_range(-1.0, 1.0)) * wander_strength

		# Integración con amortiguación (velocity de CharacterBody3D como
		# almacenamiento; el movimiento es directo sobre position)
		var vel: Vector3 = enano.velocity + accel * delta
		vel = vel.lerp(Vector3.ZERO, minf(3.0 * delta, 1.0))
		vel = vel.limit_length(max_speed)
		enano.velocity = vel
		enano.position += vel * delta
		enano.position.y = 0.0


func _on_upgrade_applied(type: UpgradeManager.UpgradeType) -> void:
	if type == UpgradeManager.UpgradeType.ADD_DWARF:
		agregar_enano()


func _sin_enanos() -> void:
	# print("[DwarfSystem] Todos los enanos eliminados — Game Over")
	ejercito_derrotado.emit()
