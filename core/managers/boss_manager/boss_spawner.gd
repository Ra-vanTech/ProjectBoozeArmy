class_name BossSpawner
extends Node3D

@export var boss_scene: PackedScene
@export var spawn_distance: float = 15.0

var _boss_spawned: bool = false

@onready var game_manager: GameManager = Services.game_manager

func _ready() -> void:
    game_manager.difficulty_manager.boss_spawned.connect(_spawn_boss)

#detector de la posicion del player para el spawn del bosss 
func _spawn_boss() -> void:
    if _boss_spawned:
        return
    _boss_spawned = true

    var player := Services.player
    var origin: Vector3 = player.global_position if is_instance_valid(player) else global_position

    var boss := boss_scene.instantiate() as Node3D
    get_tree().current_scene.add_child(boss)

    var angle := randf() * TAU
    boss.global_position = origin + Vector3(cos(angle) * spawn_distance, 1.5, sin(angle) * spawn_distance)
