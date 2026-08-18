extends Node

## Punto de acceso único a los nodos centrales de la partida (autoload
## "Services").
##
## Antes cada script que necesitaba un gestor lo buscaba con
## get_tree().get_first_node_in_group("game_manager"): 37 llamadas repartidas
## por el proyecto. Eso tenía tres problemas — coste (algunas caían en rutas
## que corren cada frame), fragilidad (el vínculo era una cadena de texto, y un
## typo no da error de compilación) y opacidad (no había forma de saber quién
## dependía de qué sin buscar por todo el repo).
##
## Aquí los nodos se registran a sí mismos al entrar al árbol. El orden es
## seguro: Godot llama a todos los _enter_tree de una escena antes que a
## cualquier _ready suyo, así que un @onready siempre encuentra lo registrado.
##
## Los grupos siguen declarados en project.godot porque las escenas los usan
## para otras cosas (p. ej. "enemy" para filtrar colisiones); lo que desaparece
## es usarlos para localizar gestores.

signal player_registrado(player: Node3D)

var game_manager: GameManager
var player: Node3D


# --- Atajos a los subgestores ---------------------------------------------
# Evitan repetir la comprobación de validez en cada llamante. Devuelven null
# si el gestor no está montado, que es lo que los guards ya esperaban.

var upgrades: UpgradeManager:
	get:
		return game_manager.upgrade_manager if is_instance_valid(game_manager) else null

var drunkeness: DrunkenessManager:
	get:
		return game_manager.drunkeness_manager if is_instance_valid(game_manager) else null

var money: MoneyManager:
	get:
		return game_manager.money_manager if is_instance_valid(game_manager) else null

var xp: XPManager:
	get:
		return game_manager.xp_manager if is_instance_valid(game_manager) else null

var difficulty: DifficultyManager:
	get:
		return game_manager.difficulty_manager if is_instance_valid(game_manager) else null


# --- Registro --------------------------------------------------------------

func registrar_game_manager(nodo: GameManager) -> void:
	game_manager = nodo


func registrar_player(nodo: Node3D) -> void:
	player = nodo
	player_registrado.emit(nodo)


## Se llama desde _exit_tree. Comprueba la identidad porque al cambiar de
## escena el nodo nuevo puede registrarse antes de que el viejo se dé de baja,
## y no debe borrar el registro del que acaba de entrar.
func dar_de_baja(nodo: Node) -> void:
	if game_manager == nodo:
		game_manager = null
	if player == nodo:
		player = null
