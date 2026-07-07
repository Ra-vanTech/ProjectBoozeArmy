class_name BeerDrop
extends DropBase


func _ready() -> void:
	$Label3D.text = str(bonus_amount) + " pts."


func pickup() -> void:
	print("[Beer]: Se recogió cerveza, la ebriedad aumentó en ", bonus_amount)
	game_manager.add_drunkeness(bonus_amount)
	queue_free()
