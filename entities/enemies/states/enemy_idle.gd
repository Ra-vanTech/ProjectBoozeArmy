class_name EnemyIdleState
extends State

@export var body: EnemyBase

@onready var input: SeekingComponent = %SeekingComponent


func tick(delta: float):
	input.tick()
	if not body.is_on_floor():
		state_machine.change_state("EnemyFallingState")
	if input.direction.length_squared() > 0.00001:
		state_machine.change_state("EnemyMovingState")
# Supongo que servirán para cambios de animación, pero por ahora más allá de para llenarme la salida del depurador no sirven para mucho
#func enter():
#	print("Enemigo en espera")
#func exit():
#	print("Enemigo saliendo de estado de espera")
