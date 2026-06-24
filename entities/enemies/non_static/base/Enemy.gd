class_name Enemy
extends EnemyBase

#variables de referencia mientras el jugador esta en contacto
var can_attack: bool = true
var player_in_range: Node3D = null

@onready var hit_box_component: HitBoxComponent = %HitBoxComponent
@onready var movement_component: MovementComponent = %MovementComponent
@onready var seeking_component: SeekingComponent = %SeekingComponent
@onready var enemy_attack_range: Area3D = %EnemyAttackRange
@onready var state_machine: StateMachine = %StateMachine


func _ready() -> void:
	hit_box_component.health_component.health = health
	hit_box_component.health_component.COINS_DROPPED_DEFAULT = COINS_DROPPED


func _process(delta: float) -> void:
	state_machine.tick(delta)


func damage(attack: Attack) -> void:
	hit_box_component.damage(attack)
	

func _on_health_component_has_died() -> void:
	state_machine.change_state("EnemyDeadState")

# Funciones para detectar que el player aun se encuentra en su rango de ataque 
func _on_enemy_attack_range_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		player_in_range = body


func _on_enemy_attack_range_body_exited(body: Node3D) -> void:
	if body.is_in_group("player") and player_in_range == body:
		player_in_range = null
