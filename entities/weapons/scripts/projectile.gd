extends RigidBody3D

@export var damage: float = 20.0
@export var speed: float = 20.0
@export var push_force: float = 10.0
@export var lifetime: float = 5.0

func _ready() -> void:
	# Configurar el proyectil
	contact_monitor = true
	max_contacts_reported = 4

	# Autodestruir después del tiempo de vida
	var timer := get_tree().create_timer(lifetime)
	timer.timeout.connect(_on_lifetime_expired)

func launch(direction: Vector3) -> void:
	# Aplicar velocidad inicial
	linear_velocity = direction.normalized() * speed

func _on_body_entered(body: Node) -> void:
	# Si golpea un RigidBody3D, aplicar fuerza
	if body is RigidBody3D:
		var push_dir: Vector3 = linear_velocity.normalized()
		body.apply_central_impulse(push_dir * push_force)
	if body.has_method("damage"):
		var attack = Attack.new()
		attack.damage = damage
		attack.knockback_force = push_force
		body.damage(attack)

	# Destruir el proyectil al impactar
	queue_free()

func _on_lifetime_expired() -> void:
	queue_free()
