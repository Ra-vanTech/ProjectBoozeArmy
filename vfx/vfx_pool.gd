extends Node

## Pool de nodos de efectos (autoload "VFXPool").
##
## Antes cada golpe creaba un Label3D o un GPUParticles3D nuevo y lo liberaba
## al terminar. En una tanda de combate eso son decenas de nodos por segundo:
## con 10 enanos golpeando a 8 enemigos son 80 nodos por ciclo de ataque, cada
## uno construyendo su material. En gama baja (MotoG24) eso se nota como
## tirones, porque un material nuevo obliga a compilar el shader en caliente.
##
## Aquí los nodos se crean una vez, se reutilizan y nunca se liberan. El tope
## de activos evita que una oleada grande llene la pantalla de etiquetas: si se
## alcanza, el efecto simplemente se omite (es feedback, no lógica de juego).

const MAX_LABELS: int = 24
const MAX_PARTICLES: int = 8
## Nodos creados por adelantado al arrancar, para que la compilación de shaders
## ocurra en la carga y no en mitad de una pelea
const PREWARM_LABELS: int = 8
const PREWARM_PARTICLES: int = 3

var _free_labels: Array[Label3D] = []
var _free_particles: Array[GPUParticles3D] = []
var _active_labels: int = 0
var _active_particles: int = 0


func _ready() -> void:
	# Los efectos se congelan con la partida, igual que cuando colgaban de la
	# escena actual
	process_mode = Node.PROCESS_MODE_PAUSABLE
	for i in range(PREWARM_LABELS):
		_free_labels.append(_crear_label())
	for i in range(PREWARM_PARTICLES):
		_free_particles.append(_crear_particles())


# --- Etiquetas flotantes ---------------------------------------------------

func _crear_label() -> Label3D:
	var label := Label3D.new()
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.no_depth_test = true
	label.outline_size = 32
	label.pixel_size = 0.005
	label.visible = false
	add_child(label)
	return label


## Devuelve una etiqueta lista para usar, o null si ya hay demasiadas en pantalla
func acquire_label() -> Label3D:
	if _active_labels >= MAX_LABELS:
		return null
	var label: Label3D = _free_labels.pop_back() if not _free_labels.is_empty() else _crear_label()
	_active_labels += 1
	label.visible = true
	return label


func release_label(label: Label3D) -> void:
	if not is_instance_valid(label):
		_active_labels = maxi(0, _active_labels - 1)
		return
	label.visible = false
	_active_labels = maxi(0, _active_labels - 1)
	_free_labels.append(label)


# --- Partículas de impacto -------------------------------------------------

# El nodo se crea "desnudo": el material y la malla los asigna CombatVFX al
# pedirlo, para que el pool no dependa de él (y no haya ciclo entre ambos)
func _crear_particles() -> GPUParticles3D:
	var particles := GPUParticles3D.new()
	particles.one_shot = true
	particles.emitting = false
	particles.amount = 12
	particles.lifetime = 0.35
	particles.explosiveness = 1.0
	particles.visible = false
	add_child(particles)
	return particles


func acquire_particles() -> GPUParticles3D:
	if _active_particles >= MAX_PARTICLES:
		return null
	var particles: GPUParticles3D = _free_particles.pop_back() if not _free_particles.is_empty() else _crear_particles()
	_active_particles += 1
	particles.visible = true
	return particles


func release_particles(particles: GPUParticles3D) -> void:
	if not is_instance_valid(particles):
		_active_particles = maxi(0, _active_particles - 1)
		return
	particles.emitting = false
	particles.visible = false
	_active_particles = maxi(0, _active_particles - 1)
	_free_particles.append(particles)
