class_name SummonComponent
extends Node

@export var summoned_enemy: PackedScene
@export var interval: float = 5.0
@export var amount: int = 1
@export var spawn_radius: float = 2.0

@export var owner_body: Node3D

var _timer: Timer

func _ready() -> void:
    _timer = Timer.new()
    _timer.wait_time = interval
    _timer.one_shot = false
    add_child(_timer)
    _timer.timeout.connect(_summon)
    _timer.start()


func _summon() -> void:
    if not summoned_enemy or not is_instance_valid(owner_body):
        return
    var parent := owner_body.get_parent()
    if not is_instance_valid(parent):
        return
    
    for i in range(amount):
        var new_enemy := summoned_enemy.instantiate() as Enemy
        parent.add_child(new_enemy)
        new_enemy.global_position = _random_position(owner_body.global_position)

func _random_position(origin: Vector3) -> Vector3:
    var angle := randf() * TAU
    var distance := randf_range(1.0, spawn_radius)
    return origin + Vector3(cos(angle) * distance, 0.0, sin(angle) * distance)


#Se trata de un invocador que no toma en cuenta el terreno 
#simplemente genera un punto alrededor del invocador y crea al enemigo, va aparte del FSM del boos 