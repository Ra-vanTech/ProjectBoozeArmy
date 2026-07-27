class_name InputComponent
extends Node

var move_direction: Vector2 = Vector2.ZERO
var has_quit: bool = false


# Lee las entradas del usuario, se actualiza desde el jugador y no acá, por eso no es _proccess
# Se separa este del componente de movimiento para poder utilizar el de movimiento cuando se quiera implementar con enemigos
func update() -> void:
	move_direction = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	if Joystick.get_direction() != Vector2.ZERO:
		move_direction = Joystick.get_direction()
	has_quit = Input.is_action_just_pressed("quit")
