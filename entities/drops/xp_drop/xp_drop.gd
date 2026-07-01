class_name XpDrop
extends DropBase

@export var xp_amount: int


func pickup() -> void:
	print("[XP Orb]: Orbe recogida, se obtuvo ", xp_amount, " experiencia")
	game_manager.add_xp(xp_amount)
	queue_free()
