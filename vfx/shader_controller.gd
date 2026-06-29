extends Camera3D

@export var smoothing_speed: float = 5.0
@export var target_position: Node3D

var contrast: float
var blur_size: Vector2

@onready var blur_layer_x: ShaderMaterial = $BlurLayer/x_blur.material
@onready var blur_layer_y: ShaderMaterial = $BlurLayer/y_blur.material
@onready var blur_layer: ShaderMaterial = $BlurLayer/blur.material
@onready var drunkeness_meter: DrunkenessMeter = get_tree().get_first_node_in_group("drunkeness")


func _physics_process(delta: float) -> void:
	fov = clamp(drunkeness_meter.drunkeness, 70, 120)

	global_transform.origin = global_transform.origin.lerp(target_position.global_transform.origin, smoothing_speed * delta)
	# global_transform.basis = global_transform.basis.slerp(target_position.global_transform.basis, smoothing_speed * delta)

	contrast = max(0.1, float(drunkeness_meter.drunkeness) / 100)
	blur_size = Vector2(contrast / 1.3, contrast / 1.3)
	blur_layer_x.set_shader_parameter("contrast", contrast)
	blur_layer_y.set_shader_parameter("contrast", contrast)
	blur_layer.set_shader_parameter("blur_size", blur_size)
