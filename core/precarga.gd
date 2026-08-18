extends Node

## Precarga y calentamiento de recursos (autoload "Precarga").
##
## El stuttering en partida no viene del trabajo por frame, sino de cosas que
## ocurren una única vez, la primera, en mitad de la acción:
##
##   - La primera muerte de un enemigo hace load() de los drops desde disco.
##   - El primer golpe crea los materiales de CombatVFX, y un material nuevo
##     obliga al driver a compilar su shader en caliente. En gama baja eso son
##     decenas de milisegundos: el tirón clásico.
##   - El primer enemigo de cada tipo, y sobre todo la aparición del jefe,
##     estrenan sus propias mallas y materiales.
##
## Aquí se adelantan las dos cosas: la lectura de disco (precargar_recursos) y
## la compilación de shaders (calentar), antes de que empiece la partida.

## Escenas que se instancian durante el juego, no al cargar el nivel. Las que
## ya son ext_resource de la escena principal no hacen falta: vienen con ella.
const ESCENAS_RUNTIME: Array[String] = [
	# Los drops son el caso más claro: hoy se cargan al morir el primer enemigo
	"res://entities/drops/xp_drop/XpDrop.tscn",
	"res://entities/drops/beer_drop/BeerDrop.tscn",
	# Enemigos: el jefe no aparece hasta el minuto 10, con todo lo suyo por
	# estrenar justo en el momento de más carga
	"res://entities/enemies/skeleton/skeleton.tscn",
	"res://entities/enemies/slime/slime.tscn",
	"res://entities/enemies/bat/bat.tscn",
	"res://entities/enemies/summoner/summoner.tscn",
	"res://entities/enemies/boss_skeleton/boss_skeleton.tscn",
	# Enanos: se instancian al empezar y al subir de nivel
	"res://entities/player/dwarves/enano_base/enano_base.tscn",
	"res://entities/player/dwarves/enano_cervecero/enano_cervecero.tscn",
	"res://entities/player/dwarves/enano_guerrero/enano_guerrero.tscn",
	"res://entities/weapons/projectile/projectile.tscn",
]

## Frames que las mallas de calentamiento pasan delante de la cámara. Dos
## bastan para que el render las procese y el shader quede compilado.
const FRAMES_CALENTAMIENTO: int = 2

var _retenidas: Dictionary = {}
var recursos_listos: bool = false


## Lee de disco y retiene las escenas. Retenerlas importa: sin una referencia
## viva, Godot puede descartarlas de la caché y el disco vuelve a tocarse.
## Conviene llamarlo mientras hay tiempo muerto (la transición del menú).
func precargar_recursos() -> void:
	if recursos_listos:
		return
	for ruta in ESCENAS_RUNTIME:
		var esc: PackedScene = load(ruta)
		if esc == null:
			push_warning("[Precarga] No se pudo precargar: " + ruta)
			continue
		_retenidas[ruta] = esc
	recursos_listos = true


## Fuerza la compilación de shaders dibujando una vez cada malla del juego y
## los materiales de CombatVFX.
##
## No instancia entidades dentro del árbol a propósito: eso dispararía sus
## _ready, y tendríamos enemigos reales corriendo por ahí. En su lugar extrae
## las mallas de cada escena y las dibuja sueltas, sin lógica asociada.
func calentar(padre: Node3D, camara: Camera3D) -> void:
	if not is_instance_valid(padre) or not is_instance_valid(camara):
		return

	var temporales: Array[Node3D] = []
	# Justo delante de la cámara y diminutas: tienen que entrar en el frustum
	# para que el render las procese, pero no deben verse
	var frente: Vector3 = camara.global_position - camara.global_transform.basis.z * 1.5

	for ruta in _retenidas:
		for datos in _extraer_mallas(_retenidas[ruta]):
			var mi := MeshInstance3D.new()
			mi.mesh = datos["mesh"]
			if datos["material"] != null:
				mi.material_override = datos["material"]
			mi.scale = Vector3.ONE * 0.001
			padre.add_child(mi)
			mi.global_position = frente
			temporales.append(mi)

	# Materiales de combate: se crean bajo demanda en el primer golpe, así que
	# se estrenan aquí en su lugar
	CombatVFX.slash_arc(padre, frente, Vector3.FORWARD, 0.01)
	# Uno por color: el material de partículas se cachea por color, y el que no
	# se caliente compilaría su shader en pleno combate
	for color in CombatVFX.colores_particulas():
		CombatVFX.hit_particles(padre, frente, color)
	# Texto con contenido real: uno vacío no genera malla y no estrenaría nada
	CombatVFX.floating_text(padre, frente, "0", Color(1, 1, 1, 0.01), 1)

	# El flash de golpe se aplica como material_override sobre la malla del
	# objetivo, así que se estrena dibujando una malla con él
	var flash := MeshInstance3D.new()
	flash.mesh = BoxMesh.new()
	flash.material_override = CombatVFX.material_flash_compartido()
	flash.scale = Vector3.ONE * 0.001
	padre.add_child(flash)
	flash.global_position = frente
	temporales.append(flash)

	for i in range(FRAMES_CALENTAMIENTO):
		await get_tree().process_frame

	for t in temporales:
		if is_instance_valid(t):
			t.queue_free()


## Devuelve [{mesh, material}] de una escena sin ejecutar su lógica: instantiate()
## no dispara _ready mientras el nodo no entre al árbol, y se libera al terminar.
func _extraer_mallas(escena: PackedScene) -> Array:
	var resultado: Array = []
	var inst: Node = escena.instantiate()
	_recoger(inst, resultado)
	inst.free() # free() y no queue_free(): nunca estuvo en el árbol
	return resultado


func _recoger(nodo: Node, salida: Array) -> void:
	if nodo is MeshInstance3D and nodo.mesh != null:
		var material: Material = nodo.material_override
		if material == null and nodo.mesh.get_surface_count() > 0:
			material = nodo.mesh.surface_get_material(0)
		salida.append({"mesh": nodo.mesh, "material": material})
	for hijo in nodo.get_children():
		_recoger(hijo, salida)
