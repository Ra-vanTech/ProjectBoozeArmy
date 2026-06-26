class_name UpgradeManager
extends Node

#tipos de mejoras disponibles 
enum UpgradeType {
    DAMAGE,
    ATTACK_SPEED,
    ADD_DWARF,
    SOBRIETY_REGEN,
    ENEMY_HP
}

var _stacks: Dictionary = {
 UpgradeType.DAMAGE: 0,
 UpgradeType.ATTACK_SPEED: 0,
 UpgradeType.ADD_DWARF: 0,
 UpgradeType.SOBRIETY_REGEN: 0,
 UpgradeType.ENEMY_HP: 0
}

#aqui viviran todos las formulas de las mejoras 

func apply_upgrade(type: UpgradeType) -> void:
    _stacks[type] += 1
    print("[UpgradeMnager] Upgradeaplicado", UpgradeType.keys()[type], "| stacks", _stacks[type])

func get_stack(type: UpgradeType) -> int:
    return _stacks[type]


# +20% de daño 
# Retorna el modificador como (1.2^n - 1) para encajar
# en la fórmula existente: damage * mod_ebriedad * (1.0 + mod_upgrades)
func get_damage_modifier() -> float:
    var stacks: int = _stacks[UpgradeType.DAMAGE]
    if stacks == 0:
        return 0.0
    return pow(1.2, stacks) - 1.0

#aumento de velocidad en ataque  x 0.85^n, minimo 0.3s
func get_cooldown_speed() -> void:
    var stacks: int = _stacks[UpgradeType.ATTACK_SPEED]
    return pow(0.85, stacks)


func get_enemy_hp() -> float:
    var stacks: int = _stacks[UpgradeType.ENEMY_HP]
    return pow(0.9, stacks)