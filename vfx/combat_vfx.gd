class_name CombatVFX


## Feedback visual de combate creado por código (sin escenas extra):
## números de daño, textos flotantes, partículas de impacto y flash de golpe.
##
## Todos los recursos (materiales y mallas) se crean una sola vez y se
## comparten. Antes cada golpe construía un StandardMaterial3D nuevo, y cada
## material nuevo obliga al driver a compilar su shader: en gama baja eso es
## justo el tirón que se sentía al pelear. Los nodos salen del pool (VFXPool)
## en vez de crearse y liberarse continuamente.

const COLOR_DANIO := Color(1.0, 0.85, 0.25)
const COLOR_SLASH := Color(1.0, 0.95, 0.6)

# Recursos compartidos, creados la primera vez que se piden
static var _malla_particula: SphereMesh
static var _mat_slash: StandardMaterial3D
static var _mat_flash: StandardMaterial3D
# GPUParticles3D no admite tinte por instancia, así que se cachea un material
# de proceso por color (hoy solo se usan dos)
static var _mats_particulas: Dictionary = {}
# Mallas de arco cacheadas por ángulo: se generan con radio 1 y se escalan al
# alcance real, así un mismo recurso sirve para cualquier alcance
static var _mallas_arco: Dictionary = {}


static func _material_particulas(color: Color) -> ParticleProcessMaterial:
	var clave: String = color.to_html(false)
	if _mats_particulas.has(clave):
		return _mats_particulas[clave]
	var mat := ParticleProcessMaterial.new()
	mat.direction = Vector3.UP
	mat.spread = 180.0
	mat.initial_velocity_min = 2.0
	mat.initial_velocity_max = 4.0
	mat.gravity = Vector3(0, -8, 0)
	mat.scale_min = 0.5
	mat.scale_max = 1.0
	mat.color = color
	_mats_particulas[clave] = mat
	return mat


static func _malla_particula_compartida() -> SphereMesh:
	if _malla_particula == null:
		_malla_particula = SphereMesh.new()
		_malla_particula.radius = 0.06
		_malla_particula.height = 0.12
		var mesh_mat := StandardMaterial3D.new()
		# El color lo aporta el ParticleProcessMaterial vía color de vértice
		mesh_mat.albedo_color = Color.WHITE
		mesh_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		mesh_mat.vertex_color_use_as_albedo = true
		_malla_particula.material = mesh_mat
	return _malla_particula


static func _material_slash() -> StandardMaterial3D:
	if _mat_slash == null:
		_mat_slash = StandardMaterial3D.new()
		_mat_slash.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		_mat_slash.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		_mat_slash.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
		_mat_slash.cull_mode = BaseMaterial3D.CULL_DISABLED
		_mat_slash.vertex_color_use_as_albedo = true
		_mat_slash.no_depth_test = true
	return _mat_slash


static func _material_flash() -> StandardMaterial3D:
	if _mat_flash == null:
		_mat_flash = StandardMaterial3D.new()
		_mat_flash.albedo_color = Color.WHITE
		_mat_flash.emission_enabled = true
		_mat_flash.emission = Color.WHITE
		_mat_flash.emission_energy_multiplier = 2.0
	return _mat_flash


static func damage_number(context: Node, pos: Vector3, amount: float) -> void:
	floating_text(context, pos, str(roundi(amount)), COLOR_DANIO)


static func floating_text(context: Node, pos: Vector3, texto: String, color: Color, font_size: int = 120) -> void:
	if not context.is_inside_tree():
		return
	var label: Label3D = VFXPool.acquire_label()
	if label == null:
		return # tope de etiquetas en pantalla: se omite el efecto
	label.text = texto
	label.font_size = font_size
	label.modulate = color
	label.global_position = pos + Vector3(randf_range(-0.4, 0.4), 1.6, randf_range(-0.2, 0.2))

	var tween := label.create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "position:y", label.position.y + 1.2, 0.7).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "modulate:a", 0.0, 0.5).set_delay(0.2)
	tween.chain().tween_callback(VFXPool.release_label.bind(label))


static func hit_particles(context: Node, pos: Vector3, color: Color) -> void:
	if not context.is_inside_tree():
		return
	var particles: GPUParticles3D = VFXPool.acquire_particles()
	if particles == null:
		return
	particles.process_material = _material_particulas(color)
	particles.draw_pass_1 = _malla_particula_compartida()
	particles.global_position = pos + Vector3.UP * 0.8
	particles.restart()
	particles.emitting = true
	# one_shot: finished se emite al acabar el ciclo y devuelve el nodo al pool.
	# ONE_SHOT desconecta sola, así que al reutilizar el nodo se vuelve a atar.
	particles.finished.connect(VFXPool.release_particles.bind(particles), CONNECT_ONE_SHOT)


## Dibuja un tajo en arco (media luna) sobre el suelo en la dirección del
## ataque, que barre y se desvanece — el área que cubre es exactamente el
## área donde el golpe hace daño.
static func slash_arc(context: Node, origin: Vector3, dir: Vector3, radius: float, arc_deg: float = 120.0, color: Color = COLOR_SLASH) -> void:
	if not context.is_inside_tree():
		return

	var mesh_inst := MeshInstance3D.new()
	mesh_inst.mesh = _malla_arco(arc_deg, color)
	mesh_inst.material_override = _material_slash()
	context.get_tree().current_scene.add_child(mesh_inst)
	mesh_inst.global_position = origin + Vector3.UP * 0.2
	# La malla se genera con radio 1: el alcance real se aplica escalando
	mesh_inst.scale = Vector3(radius, 1.0, radius)
	mesh_inst.rotation.y = atan2(dir.x, dir.z)

	var tween := mesh_inst.create_tween()
	tween.set_parallel(true)
	tween.tween_property(mesh_inst, "rotation:y", mesh_inst.rotation.y - deg_to_rad(25.0), 0.2)
	tween.tween_property(mesh_inst, "transparency", 1.0, 0.25).set_ease(Tween.EASE_IN)
	tween.chain().tween_callback(mesh_inst.queue_free)


## Malla de media luna de radio 1 apuntando a +Z, cacheada por ángulo de arco.
static func _malla_arco(arc_deg: float, color: Color) -> Mesh:
	var clave: String = "%d_%s" % [roundi(arc_deg), color.to_html(false)]
	if _mallas_arco.has(clave):
		return _mallas_arco[clave]

	var im := ImmediateMesh.new()
	var half_arc := deg_to_rad(arc_deg) * 0.5
	var inner_radius := 0.35
	var steps := 16
	var inner_color := Color(color.r, color.g, color.b, 0.0)
	var outer_color := Color(color.r, color.g, color.b, 0.85)

	im.surface_begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in range(steps):
		var a0 := -half_arc + deg_to_rad(arc_deg) * float(i) / float(steps)
		var a1 := -half_arc + deg_to_rad(arc_deg) * float(i + 1) / float(steps)
		var in0 := Vector3(sin(a0), 0, cos(a0)) * inner_radius
		var in1 := Vector3(sin(a1), 0, cos(a1)) * inner_radius
		var out0 := Vector3(sin(a0), 0, cos(a0))
		var out1 := Vector3(sin(a1), 0, cos(a1))
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

	_mallas_arco[clave] = im
	return im


## Pinta el MeshInstance3D del objetivo de blanco por un instante para que
## se lea el impacto (estilo Vampire Survivors).
static func hit_flash(target: Node3D) -> void:
	# VisualRef y no get_node_or_null("MeshInstance3D"): así sigue funcionando
	# cuando los placeholders se sustituyan por modelos importados
	var mesh := VisualRef.obtener(target)
	if mesh == null or mesh.material_override != null:
		return
	mesh.material_override = _material_flash()
	var tween := mesh.create_tween()
	tween.tween_interval(0.08)
	tween.tween_callback(_clear_flash.bind(mesh))


static func _clear_flash(mesh: MeshInstance3D) -> void:
	if is_instance_valid(mesh):
		mesh.material_override = null
