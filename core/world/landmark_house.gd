class_name LandmarkHouse
extends StaticBody3D

# Casa placeholder que sirve de punto de referencia en el mundo toroidal.
# Color y etiqueta configurables por instancia desde el inspector.

@export var color: Color = Color(0.75, 0.25, 0.2)
@export var label_text: String = "CASA"


func _ready() -> void:
	var wall_mat := StandardMaterial3D.new()
	wall_mat.albedo_color = color
	$Walls.material_override = wall_mat

	var roof_mat := StandardMaterial3D.new()
	roof_mat.albedo_color = color.darkened(0.45)
	$Roof.material_override = roof_mat

	$Label3D.text = label_text
