class_name XpDrop
extends DropBase


func _ready() -> void:
	var upgrade_manager: UpgradeManager = Services.upgrades
	bonus_amount = bonus_amount + Store.save[Store.DATA.XP_BONUS] + upgrade_manager.get_xp_bonus()
	$Label3D.text = str(bonus_amount) + " XP"


func pickup() -> void:
	game_manager.add_xp(bonus_amount)
	queue_free()
