extends Camera3D

@export var smoothing_speed: float = 10.0
@export var target_position: Node3D
@export var target_look: Node3D

var contrast: float
var blur_size: Vector2

@onready var blur_layer_x: ShaderMaterial = $BlurLayer/x_blur.material
@onready var blur_layer_y: ShaderMaterial = $BlurLayer/y_blur.material
@onready var blur_layer: ShaderMaterial = $BlurLayer/blur.material
@onready var game_manager: GameManager = get_tree().get_first_node_in_group("game_manager")


func _physics_process(delta: float) -> void:
	fov = clamp(game_manager.get_drunkenness(), 70, 100)

	global_transform.origin = global_transform.origin.lerp(target_position.global_transform.origin, smoothing_speed * delta)
	look_at(target_look.global_position)

	contrast = clamp(game_manager.get_drunkenness() / 100.0, 0.1, 1) # con límites más altos se empieza a ver desagradable
	blur_size = Vector2(contrast / 1.3, contrast / 1.3)
	blur_layer_x.set_shader_parameter("contrast", contrast)
	blur_layer_y.set_shader_parameter("contrast", contrast)
	blur_layer.set_shader_parameter("blur_size", blur_size)
