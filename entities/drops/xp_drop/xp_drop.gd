class_name XpDrop
extends DropBase


func _ready() -> void:
	$Label3D.text = str(bonus_amount) + " XP"


func pickup() -> void:
	game_manager.add_xp(bonus_amount)
	queue_free()
