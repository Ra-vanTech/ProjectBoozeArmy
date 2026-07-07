class_name InputComponent
extends Node

var move_direction: Vector2 = Vector2.ZERO
var is_jumping: bool = false
var is_shooting: bool = false
var has_quit: bool = false
var wants_spawn: bool = false
var wants_despawn: bool = false


# Lee las entradas del usuario, se actualiza desde el jugador y no acá, por eso no es _proccess
# Se separa este del componente de movimiento para poder utilizar el de movimiento cuando se quiera implementar con enemigos
func update() -> void:
	move_direction = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	is_jumping = Input.is_action_just_pressed("jump")
	is_shooting = Input.is_action_just_pressed("shoot")
	has_quit = Input.is_action_just_pressed("quit")
	# IMPLEMENTACIÓN TEMPORAL
	wants_spawn = Input.is_action_just_pressed("spawn_dwarf")
	wants_despawn = Input.is_action_just_pressed("despawn_dwarf")
