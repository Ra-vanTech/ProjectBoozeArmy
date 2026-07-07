class_name XpDrop
extends DropBase


func _ready() -> void:
	$Label3D.text = str(bonus_amount) + " XP"


func pickup() -> void:
	print("[XP Orb]: Orbe recogida, se obtuvo ", bonus_amount, " experiencia")
	game_manager.add_xp(bonus_amount)
	queue_free()
