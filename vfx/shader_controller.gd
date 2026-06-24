extends Camera3D

var contrast: float

@onready var blur_layer_x: ShaderMaterial = $BlurLayer/x_blur.material
@onready var blur_layer_y: ShaderMaterial = $BlurLayer/y_blur.material
@onready var drunkeness_meter: DrunkenessMeter = get_tree().get_first_node_in_group("drunkeness")


func _process(delta: float) -> void:
	contrast = max(0.1, float(drunkeness_meter.drunkeness) / 100)
	blur_layer_x.set_shader_parameter("contrast", contrast)
	blur_layer_y.set_shader_parameter("contrast", contrast)
