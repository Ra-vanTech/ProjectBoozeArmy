extends Camera3D

@export var smoothing_speed: float = 10.0
@export var target_position: Node3D
@export var target_look: Node3D

# El efecto de ebriedad ya no mapea el FOV 1:1 con el valor (antes cada tick
# de ebriedad pegaba un salto de FOV y el blur estaba activo siempre, lo que
# mareaba sin comunicar nada). Ahora: FOV fijo en juego normal, y solo al
# entrar al rango "ebrio" (>ZONA_EBRIA) el FOV se abre unos grados y aparece
# el blur, ambos con transición suave.
@export var base_fov: float = 75.0
@export var drunk_fov_extra: float = 8.0
@export var fov_smoothing: float = 2.0

var contrast: float
var blur_size: Vector2

@onready var blur_layer_x: ShaderMaterial = $BlurLayer/x_blur.material
@onready var blur_layer_y: ShaderMaterial = $BlurLayer/y_blur.material
@onready var blur_layer: ShaderMaterial = $BlurLayer/blur.material
@onready var drunkeness_meter: DrunkenessManager = get_tree().get_first_node_in_group("game_manager").drunkeness_manager


func _physics_process(delta: float) -> void:
	global_transform.origin = global_transform.origin.lerp(target_position.global_transform.origin, smoothing_speed * delta)
	look_at(target_look.global_position)

	# 0 en zona normal/sobria, sube linealmente hasta 1 con ebriedad máxima
	var drunk_excess: float = clampf(
		float(drunkeness_meter.drunkeness - DrunkenessManager.ZONA_EBRIA)
		/ float(drunkeness_meter.max_drunkeness - DrunkenessManager.ZONA_EBRIA),
		0.0, 1.0)

	fov = lerpf(fov, base_fov + drunk_fov_extra * drunk_excess, fov_smoothing * delta)

	contrast = lerpf(contrast, drunk_excess * 0.6, fov_smoothing * delta)
	blur_size = Vector2(contrast / 1.3, contrast / 1.3)
	blur_layer_x.set_shader_parameter("contrast", contrast)
	blur_layer_y.set_shader_parameter("contrast", contrast)
	blur_layer.set_shader_parameter("blur_size", blur_size)
