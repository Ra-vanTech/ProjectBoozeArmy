# Reemplaza a EnemyAttackState para el invocador
class_name EnemySummoningState
extends State

@export var summoned_enemy: PackedScene


# No necesita tick pq la acción solo se hace una vez
func enter():
	print("[Summoner]: Invocando enemigos")
	state_machine.change_state("EnemyMovingState")


func exit():
	print("[Summoner]: Saliendo de estado de invocación")
