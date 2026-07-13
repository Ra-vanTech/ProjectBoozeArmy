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


func get_drunkenness() -> int:
	return drunkeness_manager.drunkeness


func add_drunkeness(input: int) -> void:
	drunkeness_manager.drunkeness += input


func get_drunkenness_multiplier() -> float:
	return drunkeness_manager.calculate_damage_multiplier()


# Toma el tiempo trancurrido y le da formato
func get_time_elapsed() -> String:
	var minutes = difficulty_manager.time_elapsed / 60
	var seconds = difficulty_manager.time_elapsed % 60
	if minutes == 0:
		minutes = "00"
	if seconds < 10:
		seconds = "0" + str(seconds)
	return str(minutes) + ":" + str(seconds)


func _on_difficulty_manager_game_ended() -> void:
	game_ended = true
