class_name Enemy
extends EnemyBase

@export var health: float = 100.0
@export var COINS_DROPPED: int = 25

@onready var hit_box_component: HitBoxComponent = %HitBoxComponent
@onready var movement_component: MovementComponent = %MovementComponent
@onready var seeking_component: SeekingComponent = %SeekingComponent
#Nuevos nodos 
@onready var enemy_attack_range: Area3D = %EnemyAttackRange
@onready var attack_cooldown: Timer = %AttackCooldown


#variables de ataque para poder configurar desde la UI 
@export var attack_damage: float = 10.0
@export var attack_cooldown_time: float = 1.5

#variables de referencia mientras el jugador esta en contacto
var can_attack: bool = true
var player_in_range: Node3D = null

func _ready() -> void:
	hit_box_component.health_component.health = health
	hit_box_component.health_component.COINS_DROPPED_DEFAULT = COINS_DROPPED
	hit_box_component.health_component.has_died.connect(_on_health_component_has_died)

    #funciones de ataque 
	attack_cooldown.wait_time = attack_cooldown_time
	enemy_attack_range.body_entered.connect(_on_attack_range_body_entered)
	enemy_attack_range.body_exited.connect(_on_attack_range_body_exited)
	attack_cooldown.timeout.connect(_on_attack_cooldown_timeout)


func _process(delta: float) -> void:
	state_machine.tick(delta)


func damage(attack: Attack) -> void:
	hit_box_component.damage(attack)


#funcion de ataque 
func _try_attack() -> void:
	if not can_attack:
		return
	
	#previene el crashed si el jugador desaparece mientras esta en rango 
	if not is_instance_valid(player_in_range):
		player_in_range = null
		return
	var attack := Attack.new()
	attack.damage = attack_damage
	player_in_range.damage(attack)
	can_attack = false
	attack_cooldown.start()


func _on_attack_range_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		player_in_range = body
		_try_attack()


func _on_attack_range_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		player_in_range = null

#reinicia el ataque cuando el cooldown termina 
func _on_attack_cooldown_timeout() -> void:
	can_attack = true
	if is_instance_valid(player_in_range):
		_try_attack()

func _on_health_component_has_died() -> void:
	queue_free()
