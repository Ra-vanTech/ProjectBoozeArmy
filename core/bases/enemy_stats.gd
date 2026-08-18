class_name EnemyStats
extends Resource

## Estadísticas base de un tipo de enemigo.
##
## Antes vivían sueltas en cada escena y repartidas entre dos nodos: la vida,
## el oro y la XP en la raíz, y la velocidad dentro del MovementComponent. Para
## añadir un enemigo había que duplicar la escena y acordarse de tocar ambos.
##
## Con el recurso, un tipo nuevo es un .tres en assets/ (o el mismo .tres
## reutilizado con otro modelo), y los valores se pueden comparar de un vistazo
## sin abrir cinco escenas.
##
## El escalado por dificultad NO se guarda aquí: estos son los valores base del
## tipo, y los multiplicadores de partida los aplica el spawner encima.

@export var nombre: String = ""

@export_group("Combate")
@export var health: float = 100.0
## Multiplicador propio del tipo sobre su velocidad base (un enemigo "rápido"
## dentro de su familia). El escalado por dificultad va aparte.
@export var speed_multiplier: float = 1.0
@export var movement_speed: float = 5.0

@export_group("Recompensas")
@export var coins_dropped: int = 25
@export var xp_value: int = 0

@export_group("Aparición")
## Los jefes se colocan a mano y no deben aparecer por el spawner ni
## desaparecer por distancia
@export var can_spawn: bool = true
