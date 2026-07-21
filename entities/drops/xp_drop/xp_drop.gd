class_name XpDrop
extends DropBase


func _ready() -> void:
	var upgrade_manager: UpgradeManager = get_tree().get_first_node_in_group("game_manager").upgrade_manager
	bonus_amount = bonus_amount + Store.save[Store.DATA.XP_BONUS] + upgrade_manager.get_xp_bonus()
	$Label3D.text = str(bonus_amount) + " XP"


func pickup() -> void:
	game_manager.add_xp(bonus_amount)
	queue_free()
