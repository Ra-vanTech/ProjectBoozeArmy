class_name GameManager
extends Node

@export var xp_manager: XPManager
@export var drunkeness_manager: DrunkenessManager
@export var upgrade_manager: UpgradeManager
@export var difficulty_manager: DifficultyManager
@export var money_manager: MoneyManager

var game_ended: bool = false


# Métodos utilizados para facilitar el acceso a las variables de cada gestor
func add_gold(input: int) -> void:
	money_manager.gold += input


func add_xp(input: int) -> void:
	xp_manager.current_xp += input


func add_drunkeness(input: int) -> void:
	drunkeness_manager.drunkeness += input


func _on_difficulty_manager_game_ended() -> void:
	game_ended = true
