class_name EnanoBase
extends Node3D

@export var damage: float = 10.0
@export var attack_cooldown_time: float = 1.2

@onready var attack_range: Area3D = $AttackRange
@onready var attack_cooldown: Timer = $AttackCooldown

var enemies_in_range: Array[Node3D] = []
var can_attack: bool = false

func _ready() -> void:
    attack_cooldown.wait_time = attack_cooldown_time
    attack_range.body_entered.connect(_on_body_entered)
    attack_range.body_exited.connect(_on_body_exited)
    attack_range.area_entered.connect(_on_area_entered)
    attack_range.area_exited.connect(_on_area_exited)
    attack_cooldown.timeout.connect(_on_attack_cooldown_timeout)
    
    # Desincronización de timers iniciales
    var initial_delay: float = randf_range(0.0, attack_cooldown_time)
    attack_cooldown.start(initial_delay)

func _process(_delta: float) -> void:
    if not can_attack:
        return
        
    #FIX: Limpiar nodos destruidos primero
    limpiar_enemigos_muertos()
    
    if enemies_in_range.size() > 0:
        _attack(enemies_in_range[0])

#FIX: Función auxiliar para evitar crashes
func limpiar_enemigos_muertos() -> void:
    for i in range(enemies_in_range.size() - 1, -1, -1):
        if not is_instance_valid(enemies_in_range[i]):
            enemies_in_range.remove_at(i)

func _attack(target: Node3D) -> void:
    if target.has_method("damage"):
        var atk := Attack.new()
        atk.damage = damage
        target.damage(atk)
        can_attack = false
        attack_cooldown.start()
        print("[DEBUG] Enano '%s' ataca en frame %d" % [name, Engine.get_process_frames()])

func _on_body_entered(body: Node3D) -> void:
    if body is EnemyBase:
        if not enemies_in_range.has(body):
            enemies_in_range.append(body)

func _on_body_exited(body: Node3D) -> void:
    enemies_in_range.erase(body)

func _on_area_entered(area: Area3D) -> void:
    var parent := area.get_parent()
    if parent is EnemyBase:
        if not enemies_in_range.has(parent):
            enemies_in_range.append(parent)

func _on_area_exited(area: Area3D) -> void:
    var parent := area.get_parent()
    if parent is EnemyBase:
        enemies_in_range.erase(parent)

func _on_attack_cooldown_timeout() -> void:
    can_attack = true