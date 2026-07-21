class_name UpgradeManager
extends Node

signal upgrade_applied(type: UpgradeType)

#tipos de mejoras disponibles
enum UpgradeType {
	DAMAGE,
	ATTACK_SPEED,
	ADD_DWARF,
	SOBRIETY_REGEN,
	ENEMY_HP,
	MAX_DRUNKENNESS,
	XP_BONUS,
	COINS_BONUS,
}

var upgrade_descriptions: Dictionary = {
	UpgradeType.DAMAGE: Descriptions.desc[Store.DATA.DMG_MAX_LVL],
	UpgradeType.ATTACK_SPEED: Descriptions.desc[Store.DATA.ATK_SPEED_MAX_LVL],
	UpgradeType.ADD_DWARF: Descriptions.desc[Store.DATA.DWARF_LIMIT_MAX_LVL],
	UpgradeType.SOBRIETY_REGEN: Descriptions.desc[Store.DATA.DRUNKENNESS_MAX_LVL],
	UpgradeType.ENEMY_HP: Descriptions.desc[Store.DATA.ENEMY_HP_REDUCTION_MAX_LVL],
}
var _stacks: Dictionary = {
	UpgradeType.DAMAGE: 0,
	UpgradeType.ATTACK_SPEED: 0,
	UpgradeType.ADD_DWARF: 0,
	UpgradeType.SOBRIETY_REGEN: 0,
	UpgradeType.ENEMY_HP: 0,
}


func item(upgrade_name: String, description: String, max_lvl: int) -> Dictionary:
	return { "name": upgrade_name, "desc": description, "max_lvl": max_lvl }


#aqui viviran todos las formulas de las mejoras
func apply_upgrade(type: UpgradeType) -> void:
	_stacks[type] += 1
	# print("[UpgradeMnager] Upgradeaplicado", UpgradeType.keys()[type], "| stacks", _stacks[type])
	upgrade_applied.emit(type)


func get_stack(type: UpgradeType) -> int:
	return _stacks[type]


func is_below_limit(i: int) -> bool:
	if upgrade_descriptions[i].max_lvl <= 0:
		return true
	return _stacks[i] < upgrade_descriptions[i].max_lvl


## Retorna las mejoras filtradas para no traer las que ya llegaron a su nivel máximo
func get_upgrade_list() -> Array:
	var filtered: Array = _stacks.keys().filter(is_below_limit)
	if len(filtered) < 3:
		# Repite mejoras para asegurar que siempre hayan 3 elementos, si esto no se hace da error de fuera del límite
		# También es posible añadir otro diccionario de mejoras más débiles pero sin límite
		for i in range(3 - len(filtered)):
			filtered.push_back(filtered.pick_random())
	filtered.shuffle()
	return filtered.slice(0, 3)


func get_level(i: UpgradeType) -> String:
	if _stacks[i] + 1 == upgrade_descriptions[i].max_lvl:
		return "MAX"
	else:
		return "Nivel " + str(_stacks[i] + 1)


# +20% de daño
# Retorna el modificador como (1.2^n - 1) para encajar
# en la fórmula existente: damage * mod_ebriedad * (1.0 + mod_upgrades)
func get_damage_modifier() -> float:
	var stacks: int = _stacks[UpgradeType.DAMAGE]
	if stacks == 0:
		return 0.0
	return pow(1.2, stacks) - 1.0


#aumento de velocidad en ataque  x 0.85^n, minimo 0.3s
func get_cooldown_speed() -> float:
	var stacks: int = _stacks[UpgradeType.ATTACK_SPEED]
	return pow(0.85, stacks)


func get_enemy_hp() -> float:
	var stacks: int = _stacks[UpgradeType.ENEMY_HP]
	return pow(0.9, stacks)
