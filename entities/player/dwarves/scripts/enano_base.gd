class_name EnanoBase
extends CharacterBody3D

@export var damage: float = 10.0
@export var cooldown_base: float = 1.0
# Los enanos cuerpo a cuerpo golpean en un arco (slash) que daña a todos los
# enemigos dentro; los de rango (futuro) golpean a un solo objetivo
@export var ataque_a_distancia: bool = false
@export var arco_ataque_grados: float = 120.0

#estado dinamico
var enemies_in_range: Array[Node3D] = []

# Alcance real del ataque: radio base de la esfera de AttackRange escalado
# por el upgrade de alcance (la esfera de detección se agranda junto con él)
var _alcance: float = 1.5
var _alcance_base: float = 1.5
var _range_shape: SphereShape3D
var _mesh_base_pos: Vector3
var _lunge_tween: Tween

@onready var attack_range: Area3D = %AttackRange
@onready var state_machine: StateMachine = %StateMachine
@onready var mesh: MeshInstance3D = get_node_or_null("MeshInstance3D")


func _ready() -> void:
	attack_range.body_entered.connect(_on_attack_range_body_entered)
	attack_range.body_exited.connect(_on_attack_range_body_exited)
	if is_instance_valid(mesh):
		_mesh_base_pos = mesh.position
	var collision := attack_range.get_node_or_null("CollisionShape3D") as CollisionShape3D
	if collision and collision.shape is SphereShape3D:
		# Copia única por instancia: el recurso de la escena es compartido y
		# no debe mutarse al escalar el radio con upgrades
		collision.shape = collision.shape.duplicate()
		_range_shape = collision.shape
		_alcance_base = _range_shape.radius
	_actualizar_alcance()
	var upgrade_manager: UpgradeManager = get_tree().get_first_node_in_group("upgrade_manager")
	if is_instance_valid(upgrade_manager):
		upgrade_manager.upgrade_applied.connect(_on_upgrade_applied)


func _on_upgrade_applied(type: UpgradeManager.UpgradeType) -> void:
	if type == UpgradeManager.UpgradeType.ATTACK_RANGE:
		_actualizar_alcance()


func _actualizar_alcance() -> void:
	var mult: float = 1.0
	var upgrade_manager: UpgradeManager = get_tree().get_first_node_in_group("upgrade_manager")
	if is_instance_valid(upgrade_manager):
		mult = upgrade_manager.get_range_multiplier()
	_alcance = _alcance_base * mult
	if _range_shape:
		_range_shape.radius = _alcance


func _physics_process(delta: float) -> void:
	state_machine.tick(delta)


# Metodos de calculo de daño (fórmulas compartidas en Attack, también las usa
# el AttackComponent del personaje central)
func obtener_daño_final() -> float:
	return Attack.danio_final(self, damage)


func obtener_cooldown_final() -> float:
	return Attack.cooldown_final(self, cooldown_base)


# Acciones base
func _attack(target: Node3D) -> void:
	if not is_instance_valid(target):
		return
	if ataque_a_distancia:
		_attack_single(target)
	else:
		_attack_slash(target)


# Enanos de rango: golpe directo a un solo objetivo
func _attack_single(target: Node3D) -> void:
	var attack := Attack.new()
	attack.damage = obtener_daño_final()
	target.damage(attack)
	_lunge(target.global_position)
	CombatVFX.hit_flash(target)
	CombatVFX.hit_particles(self, target.global_position, CombatVFX.COLOR_DANIO)
	CombatVFX.damage_number(self, target.global_position, attack.damage)


# Enanos cuerpo a cuerpo: tajo en arco hacia el objetivo que daña a todos los
# enemigos dentro (estilo Vampire Survivors); el VFX cubre exactamente el
# área afectada
func _attack_slash(target: Node3D) -> void:
	var danio: float = obtener_daño_final()
	var dir: Vector3 = target.global_position - global_position
	dir.y = 0.0
	dir = dir.normalized()
	var half_arc: float = deg_to_rad(arco_ataque_grados) * 0.5

	for enemy in enemies_in_range:
		if not is_instance_valid(enemy):
			continue
		var to_enemy: Vector3 = enemy.global_position - global_position
		to_enemy.y = 0.0
		if to_enemy.length() > _alcance or dir.angle_to(to_enemy.normalized()) > half_arc:
			continue
		var attack := Attack.new()
		attack.damage = danio
		enemy.damage(attack)
		CombatVFX.hit_flash(enemy)
		CombatVFX.damage_number(self, enemy.global_position, danio)

	_lunge(target.global_position)
	CombatVFX.slash_arc(self, global_position, dir, _alcance, arco_ataque_grados)


# Embestida corta del enano hacia el objetivo para que se lea quién atacó
func _lunge(target_pos: Vector3) -> void:
	if not is_instance_valid(mesh):
		return
	var local_dir: Vector3 = global_transform.basis.inverse() * \
			(target_pos - global_position).normalized()
	if is_instance_valid(_lunge_tween):
		_lunge_tween.kill()
	_lunge_tween = create_tween()
	_lunge_tween.tween_property(mesh, "position", _mesh_base_pos + local_dir * 0.45, 0.07)
	_lunge_tween.tween_property(mesh, "position", _mesh_base_pos, 0.12)


# señales de deteccion
func _on_attack_range_body_entered(body: Node3D) -> void:
	if body.is_in_group("enemy") and not enemies_in_range.has(body):
		enemies_in_range.append(body)


func _on_attack_range_body_exited(body: Node3D) -> void:
	if body.is_in_group("enemy") and enemies_in_range.has(body):
		enemies_in_range.erase(body)
