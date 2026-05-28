class_name EnanoBase
extends CharacterBody3D

@onready var attack_range: Area3D = %AttackRange
@onready var state_machine: StateMachine = %StateMachine

@export var damage: float = 10.0
@export var cooldown_base: float = 1.0

#estado dinamico 
var enemies_in_range: Array[Node3D] = []

func _ready() -> void:
  attack_range.body_entered.connect(_on_attack_range_body_entered)
  attack_range.body_exited.connect(_on_attack_range_body_exited)


func _physics_process(delta: float) -> void:
    #comportamiento de FSM
  state_machine.tick(delta)


# Metodos de calculo de daño 
func obtener_modificador_ebriedad() -> float:
    return 1.0 # simula el nivel 1

func obtener_modificador_upgrades() -> float:
    return 0.0 # simula el nivel 1

func obtener_daño_final() -> float:
    var mod_ebriedad: float = obtener_modificador_ebriedad()
    var mod_upgrades: float = obtener_modificador_upgrades()

    #retorna la formula de daño final 
    return damage * mod_ebriedad * (1.0 + mod_upgrades)


# Acciones base (poliformismo) 
func _attack(target: Node3D) -> void:
   if not is_instance_valid(target):
    return
   var attack := Attack.new()
   attack.damage = obtener_daño_final()
   target.damage(attack)

# señales de deteccion 
func _on_attack_range_body_entered(body: Node3D) -> void:
    if body.is_in_group("enemy") and not enemies_in_range.has(body):
      enemies_in_range.append(body)

func _on_attack_range_body_exited(body: Node3D) -> void:
    if body.is_in_group("enemy") and enemies_in_range.has(body):
        enemies_in_range.erase(body)