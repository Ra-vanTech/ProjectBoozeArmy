class_name Bank
extends Label

@export var STARTING_GOLD: int = 0

var gold: int:
	set(gold_in):
		gold = max(gold_in, 0)
		text = "Gold: " + str(gold)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	gold = STARTING_GOLD


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
