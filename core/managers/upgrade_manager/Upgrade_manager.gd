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
	ATTACK_RANGE,
}

# Aparecen como lista del 0 al 5 en orden
## Permite limitar la cantidad de veces que una mejora se puede seleccionar.
## Colocar 0 como límite hace que la mejora se pueda seleccionar infinitas veces
@export var upgrade_limits: Dictionary = {
	UpgradeType.DAMAGE: 10,
	UpgradeType.ATTACK_SPEED: 10,
	UpgradeType.ADD_DWARF: 0,
	UpgradeType.SOBRIETY_REGEN: 1,
	UpgradeType.ENEMY_HP: 9,
	UpgradeType.ATTACK_RANGE: 5,
}

var _stacks: Dictionary = {
	UpgradeType.DAMAGE: 0,
	UpgradeType.ATTACK_SPEED: 0,
	UpgradeType.ADD_DWARF: 0,
	UpgradeType.SOBRIETY_REGEN: 0,
	UpgradeType.ENEMY_HP: 0,
	UpgradeType.ATTACK_RANGE: 0,
}


#aqui viviran todos las formulas de las mejoras
func apply_upgrade(type: UpgradeType) -> void:
	_stacks[type] += 1
	# print("[UpgradeMnager] Upgradeaplicado", UpgradeType.keys()[type], "| stacks", _stacks[type])
	upgrade_applied.emit(type)


func get_stack(type: UpgradeType) -> int:
	return _stacks[type]


func is_below_limit(i: int) -> bool:
	if upgrade_limits[i] <= 0:
		return true
	return _stacks[i] < upgrade_limits[i]


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


# +15% de alcance de ataque por stack (multiplica el radio base)
func get_range_multiplier() -> float:
	var stacks: int = _stacks[UpgradeType.ATTACK_RANGE]
	return pow(1.15, stacks)
