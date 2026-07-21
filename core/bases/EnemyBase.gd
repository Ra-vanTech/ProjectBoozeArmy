class_name EnemyBase
extends CharacterBody3D

# signal enemy_died(xp_amount: int)
@export var health: float = 100.0
@export var COINS_DROPPED: int = 25
@export var speed_multiplier: float = 1.0
#valor xp por tipo
# esqueleto: 5 | smile: 8 | murcielago: 4 | Invocador 10
@export var xp_value: int = 0

@export var can_spawn: bool = true