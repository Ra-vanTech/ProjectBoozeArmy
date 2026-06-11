class_name EnanoBase
extends CharacterBody3D

@export var damage: float = 10.0
@export var cooldown_base: float = 1.0

#estado dinamico
var enemies_in_range: Array[Node3D] = []
var drunkeness_meter: DrunkenessMeter = get_tree().get_first_node_in_group("drunkeness")

@onready var attack_range: Area3D = %AttackRange
@onready var state_machine: StateMachine = %StateMachine


func _ready() -> void:
	attack_range.body_entered.connect(_on_attack_range_body_entered)
	attack_range.body_exited.connect(_on_attack_range_body_exited)


func _physics_process(delta: float) -> void:
	state_machine.tick(delta)


# Metodos de calculo de daño
func obtener_modificador_ebriedad() -> float:
	if not is_instance_valid(drunkeness_meter):
		return 1.0 # siempre retorna 1 por defecto (seguro)
	var level: int = drunkeness_meter.drunkeness
	if level == 0 or level < 30:
		return 0.7 # sobrio /critico (-%30)
	elif level <= 70:
		return 1.0 # moderado (normal)
	else:
		return 1.3 # ebrio (%30)


func obtener_modificador_upgrades() -> float:
	return 0.0 # simula el nivel 1


func obtener_daño_final() -> float:
	var mod_ebriedad: float = obtener_modificador_ebriedad()
	var mod_upgrades: float = obtener_modificador_upgrades()
	#retorna la formula de daño final
	return damage * mod_ebriedad * (1.0 + mod_upgrades)


# Acciones base 
func _attack(target: Node3D) -> void:
	if not is_instance_valid(target):
		return
	var attack := Attack.new()
	attack.damage = obtener_daño_final()
	target.damage(attack)


#Obtener cooldown final, +20% de velocidad en rango ebrio 
func obtener_cooldown_final() -> float:
	if not is_instance_valid(drunkeness_meter):
		return cooldown_base

	if drunkeness_meter.drunkeness > 70:
		return cooldown_base * 0.8
		
	return cooldown_base
		

# señales de deteccion
func _on_attack_range_body_entered(body: Node3D) -> void:
	if body.is_in_group("enemy") and not enemies_in_range.has(body):
		enemies_in_range.append(body)


func _on_attack_range_body_exited(body: Node3D) -> void:
	if body.is_in_group("enemy") and enemies_in_range.has(body):
		enemies_in_range.erase(body)
