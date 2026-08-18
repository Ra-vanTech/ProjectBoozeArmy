class_name Precalentador
extends Node

## Dispara el calentamiento al arrancar el nivel. Va como nodo de la escena de
## partida porque necesita la cámara activa: las mallas tienen que pasar por el
## frustum para que sus shaders se compilen.
##
## Si se entra al nivel desde el menú, los recursos ya vendrán leídos de disco
## (el menú lo hace durante el fade); si se arranca la escena directamente
## desde el editor, se leen aquí.

## Congela la partida mientras calienta. Son un par de frames, pero evitan que
## los enemigos avancen durante ellos.
@export var pausar_durante_calentamiento: bool = true


func _ready() -> void:
	# Un frame de margen para que la cámara y el resto de la escena existan
	await get_tree().process_frame

	var camara: Camera3D = get_viewport().get_camera_3d()
	if camara == null:
		push_warning("[Precalentador] Sin cámara activa: se omite el calentamiento")
		return

	var pausado_antes: bool = get_tree().paused
	if pausar_durante_calentamiento:
		get_tree().paused = true

	Precarga.precargar_recursos()
	await Precarga.calentar(get_parent() as Node3D, camara)

	if pausar_durante_calentamiento:
		get_tree().paused = pausado_antes
