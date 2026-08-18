class_name DeadState
extends State


func enter():
	get_tree().paused = true
	# La pantalla se muestra sola al oír el evento: antes este estado la
	# buscaba por grupo y le cambiaba el visible a mano
	Events.jugador_muerto.emit()
