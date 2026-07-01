class_name MoneyManager
extends Node

signal gold_changed(gold: int)

@export var STARTING_GOLD: int = 0

var gold: int:
	set(gold_in):
		gold = max(gold_in, 0)
		gold_changed.emit(gold)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	gold = STARTING_GOLD


func add_gold(new_gold: int) -> void:
	gold += new_gold
