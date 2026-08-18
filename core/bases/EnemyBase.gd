class_name EnemyBase
extends CharacterBody3D

## Estadísticas del tipo. Si se asigna, sus valores sustituyen a los campos de
## abajo al arrancar. Estos siguen existiendo porque son el estado vivo del
## enemigo (el spawner escala la vida por dificultad) y para que las escenas
## que aún no tengan .tres sigan funcionando durante la transición.
@export var stats: EnemyStats

# signal enemy_died(xp_amount: int)
@export var health: float = 100.0
@export var COINS_DROPPED: int = 25
@export var speed_multiplier: float = 1.0
#valor xp por tipo
# esqueleto: 5 | smile: 8 | murcielago: 4 | Invocador 10
@export var xp_value: int = 0

@export var can_spawn: bool = true


## Vuelca el recurso sobre los campos vivos. Se llama al principio de _ready,
## antes de que nadie los lea.
func aplicar_stats() -> void:
	if stats == null:
		return
	health = stats.health
	COINS_DROPPED = stats.coins_dropped
	xp_value = stats.xp_value
	speed_multiplier = stats.speed_multiplier
	can_spawn = stats.can_spawn