class_name CombatVFX


## Feedback visual de combate creado por código (sin escenas extra):
## números de daño, textos flotantes, partículas de impacto y flash de golpe.
## Todos los nodos se agregan a la escena actual y se autodestruyen al terminar.

const COLOR_DANIO := Color(1.0, 0.85, 0.25)


static func damage_number(context: Node, pos: Vector3, amount: float) -> void:
	floating_text(context, pos, str(roundi(amount)), COLOR_DANIO)


static func floating_text(context: Node, pos: Vector3, texto: String, color: Color, font_size: int = 120) -> void:
	if not context.is_inside_tree():
		return
	var label := Label3D.new()
	label.text = texto
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.no_depth_test = true
	label.font_size = font_size
	label.outline_size = 32
	label.modulate = color
	label.pixel_size = 0.005
	context.get_tree().current_scene.add_child(label)
	label.global_position = pos + Vector3(randf_range(-0.4, 0.4), 1.6, randf_range(-0.2, 0.2))
	var tween := label.create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "position:y", label.position.y + 1.2, 0.7).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "modulate:a", 0.0, 0.5).set_delay(0.2)
	tween.chain().tween_callback(label.queue_free)


static func hit_particles(context: Node, pos: Vector3, color: Color) -> void:
	if not context.is_inside_tree():
		return
	var particles := GPUParticles3D.new()
	particles.one_shot = true
	particles.emitting = true
	particles.amount = 12
	particles.lifetime = 0.35
	particles.explosiveness = 1.0

	var mat := ParticleProcessMaterial.new()
	mat.direction = Vector3.UP
	mat.spread = 180.0
	mat.initial_velocity_min = 2.0
	mat.initial_velocity_max = 4.0
	mat.gravity = Vector3(0, -8, 0)
	mat.scale_min = 0.5
	mat.scale_max = 1.0
	particles.process_material = mat

	var mesh := SphereMesh.new()
	mesh.radius = 0.06
	mesh.height = 0.12
	var mesh_mat := StandardMaterial3D.new()
	mesh_mat.albedo_color = color
	mesh_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mesh.material = mesh_mat
	particles.draw_pass_1 = mesh

	context.get_tree().current_scene.add_child(particles)
	particles.global_position = pos + Vector3.UP * 0.8
	particles.finished.connect(particles.queue_free)


## Dibuja un tajo en arco (media luna) sobre el suelo en la dirección del
## ataque, que barre y se desvanece — el área que cubre es exactamente el
## área donde el golpe hace daño.
static func slash_arc(context: Node, origin: Vector3, dir: Vector3, radius: float, arc_deg: float = 120.0, color: Color = Color(1.0, 0.95, 0.6)) -> void:
	if not context.is_inside_tree():
		return
	var im := ImmediateMesh.new()
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat.vertex_color_use_as_albedo = true
	mat.no_depth_test = true

	# Media luna: borde interior tenue, borde exterior brillante
	var base_angle := atan2(dir.x, dir.z)
	var half_arc := deg_to_rad(arc_deg) * 0.5
	var inner_radius := radius * 0.35
	var steps := 16
	var inner_color := Color(color.r, color.g, color.b, 0.0)
	var outer_color := Color(color.r, color.g, color.b, 0.85)

	im.surface_begin(Mesh.PRIMITIVE_TRIANGLES, mat)
	for i in range(steps):
		var a0 := base_angle - half_arc + deg_to_rad(arc_deg) * float(i) / float(steps)
		var a1 := base_angle - half_arc + deg_to_rad(arc_deg) * float(i + 1) / float(steps)
		var in0 := Vector3(sin(a0), 0, cos(a0)) * inner_radius
		var in1 := Vector3(sin(a1), 0, cos(a1)) * inner_radius
		var out0 := Vector3(sin(a0), 0, cos(a0)) * radius
		var out1 := Vector3(sin(a1), 0, cos(a1)) * radius
		im.surface_set_color(inner_color)
		im.surface_add_vertex(in0)
		im.surface_set_color(outer_color)
		im.surface_add_vertex(out0)
		im.surface_add_vertex(out1)
		im.surface_set_color(inner_color)
		im.surface_add_vertex(in0)
		im.surface_set_color(outer_color)
		im.surface_add_vertex(out1)
		im.surface_set_color(inner_color)
		im.surface_add_vertex(in1)
	im.surface_end()

	var mesh_inst := MeshInstance3D.new()
	mesh_inst.mesh = im
	context.get_tree().current_scene.add_child(mesh_inst)
	mesh_inst.global_position = origin + Vector3.UP * 0.2

	var tween := mesh_inst.create_tween()
	tween.set_parallel(true)
	tween.tween_property(mesh_inst, "rotation:y", mesh_inst.rotation.y - deg_to_rad(25.0), 0.2)
	tween.tween_property(mesh_inst, "transparency", 1.0, 0.25).set_ease(Tween.EASE_IN)
	tween.chain().tween_callback(mesh_inst.queue_free)


## Pinta el MeshInstance3D del objetivo de blanco por un instante para que
## se lea el impacto (estilo Vampire Survivors).
static func hit_flash(target: Node3D) -> void:
	var mesh := target.get_node_or_null("MeshInstance3D") as MeshInstance3D
	if mesh == null or mesh.material_override != null:
		return
	var flash := StandardMaterial3D.new()
	flash.albedo_color = Color.WHITE
	flash.emission_enabled = true
	flash.emission = Color.WHITE
	flash.emission_energy_multiplier = 2.0
	mesh.material_override = flash
	var tween := mesh.create_tween()
	tween.tween_interval(0.08)
	tween.tween_callback(_clear_flash.bind(mesh))


static func _clear_flash(mesh: MeshInstance3D) -> void:
	if is_instance_valid(mesh):
		mesh.material_override = null
