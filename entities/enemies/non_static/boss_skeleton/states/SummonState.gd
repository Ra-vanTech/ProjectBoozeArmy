class_name EnemySummonState
extends State

@export var summoned_enemy: PackedScene
@export var amount: int = 2
@export var spawn_radius: float = 3.5

@export var owner_body: Node3D


func enter() -> void:
    _summon()
    _decide_next_state()

func _summon() -> void:
    if not summoned_enemy or not is_instance_valid(owner_body):
        return
    var parent := owner_body.get_parent()
    if not is_instance_valid(parent):
        return
    
    for i in range(amount):
        var new_enemy := summoned_enemy.instantiate() as Node3D
        parent.add_child(new_enemy)
        new_enemy.global_position = _random_position(owner_body.global_position)

func _random_position(origin: Vector3) -> Vector3:
    var angle := randf() * TAU
    var distance := randf_range(1.0, spawn_radius)
    return origin + Vector3(cos(angle) * distance, 0.0, sin(angle) * distance)


func _decide_next_state() -> void:
    if is_instance_valid(owner_body.player_in_range):
        state_machine.change_state("EnemyAttackState")
    else:
        state_machine.change_state("EnemyMovingState")


#Se trata de un invocador que no toma en cuenta el terreno 
#simplemente genera un punto alrededor del invocador y crea al enemigo,