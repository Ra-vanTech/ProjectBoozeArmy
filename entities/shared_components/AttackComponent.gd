class_name AttackComponent
extends Node

## Ataque cuerpo a cuerpo automático en arco, con las mismas reglas que los
## enanos (fórmulas compartidas en Attack). Se cuelga de cualquier cuerpo con
## un Area3D de detección — lo usa el personaje central para pelear como un
## enano más.

@export var attack_area: Area3D
@export var damage: float = 10.0
@export var cooldown_base: float = 1.2
@export var arco_ataque_grados: float = 120.0

var enemies_in_range: Array[Node3D] = []
var _cooldown: float = 0.0
var _alcance: float = 1.5
var _alcance_base: float = 1.5
var _range_shape: SphereShape3D

@onready var body: Node3D = owner


func _ready() -> void:
	attack_area.body_entered.connect(_on_body_entered)
	attack_area.body_exited.connect(_on_body_exited)
	var collision := attack_area.get_node_or_null("CollisionShape3D") as CollisionShape3D
	if collision and collision.shape is SphereShape3D:
		# Copia única por instancia para escalar el radio con upgrades sin
		# mutar el recurso compartido de la escena
		collision.shape = collision.shape.duplicate()
		_range_shape = collision.shape
		_alcance_base = _range_shape.radius
	_actualizar_alcance()
	var upgrade_manager: UpgradeManager = get_tree().get_first_node_in_group("upgrade_manager")
	if is_instance_valid(upgrade_manager):
		upgrade_manager.upgrade_applied.connect(_on_upgrade_applied)
	# Fase inicial aleatoria para no sincronizarse con los enanos
	_cooldown = randf_range(0.0, Attack.cooldown_final(self, cooldown_base))


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
	enemies_in_range = enemies_in_range.filter(func(e): return is_instance_valid(e))
	if enemies_in_range.is_empty():
		return
	_cooldown += delta
	if _cooldown < Attack.cooldown_final(self, cooldown_base):
		return
	_cooldown = 0.0
	_slash(_closest_enemy())


func _slash(target: Node3D) -> void:
	if not is_instance_valid(target):
		return
	var danio: float = Attack.danio_final(self, damage)
	var dir: Vector3 = target.global_position - body.global_position
	dir.y = 0.0
	dir = dir.normalized()
	var half_arc: float = deg_to_rad(arco_ataque_grados) * 0.5

	for enemy in enemies_in_range:
		var to_enemy: Vector3 = enemy.global_position - body.global_position
		to_enemy.y = 0.0
		if to_enemy.length() > _alcance or dir.angle_to(to_enemy.normalized()) > half_arc:
			continue
		var attack := Attack.new()
		attack.damage = danio
		enemy.damage(attack)
		CombatVFX.hit_flash(enemy)
		CombatVFX.damage_number(self, enemy.global_position, danio)

	CombatVFX.slash_arc(self, body.global_position, dir, _alcance, arco_ataque_grados)


func _closest_enemy() -> Node3D:
	var closest: Node3D = null
	var shortest: float = INF
	for enemy in enemies_in_range:
		var dist: float = body.global_position.distance_squared_to(enemy.global_position)
		if dist < shortest:
			shortest = dist
			closest = enemy
	return closest


func _on_body_entered(other: Node3D) -> void:
	if other.is_in_group("enemy") and not enemies_in_range.has(other):
		enemies_in_range.append(other)


func _on_body_exited(other: Node3D) -> void:
	if other.is_in_group("enemy"):
		enemies_in_range.erase(other)
