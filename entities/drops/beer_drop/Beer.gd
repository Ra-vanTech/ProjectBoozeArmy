class_name BeerDrop
extends DropBase


func _ready() -> void:
	$Label3D.text = str(bonus_amount) + " pts."


func pickup() -> void:
	game_manager.add_drunkeness(bonus_amount)
	CombatVFX.floating_text(self, global_position, "+%d ebriedad" % bonus_amount, Color(0.4, 0.9, 0.3))
	queue_free()
