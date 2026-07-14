class_name Attack


var damage: float = 10.0
var knockback_force: float = 20.0
var stun_time: float = 0.0
var attack_direction: Vector2 = Vector2.ZERO


# Fórmulas de combate compartidas por los enanos y el personaje central,
# para que todos peguen bajo las mismas reglas de ebriedad/upgrades.
# `context` es cualquier nodo dentro del árbol (para acceder a los managers).

static func modificador_ebriedad(context: Node) -> float:
	var game_manager: GameManager = context.get_tree().get_first_node_in_group("game_manager")
	if not is_instance_valid(game_manager):
		return 1.0 # siempre retorna 1 por defecto (seguro)
	# La fórmula por zonas (y el bono por encima de 100) vive en DrunkenessManager
	return game_manager.get_drunkenness_multiplier()


static func modificador_upgrades(context: Node) -> float:
	var upgrade_manager: UpgradeManager = context.get_tree().get_first_node_in_group("upgrade_manager")
	if not is_instance_valid(upgrade_manager):
		return 0.0
	return upgrade_manager.get_damage_modifier()


static func danio_final(context: Node, base: float) -> float:
	return base * modificador_ebriedad(context) * (1.0 + modificador_upgrades(context))


#Cooldown final, +20% de velocidad en rango ebrio, límite mínimo 0.3s
static func cooldown_final(context: Node, base: float) -> float:
	var cooldown: float = base
	var game_manager: GameManager = context.get_tree().get_first_node_in_group("game_manager")
	if is_instance_valid(game_manager) and game_manager.get_drunkenness() > DrunkenessManager.ZONA_EBRIA:
		cooldown *= 0.8

	var upgrade_manager: UpgradeManager = context.get_tree().get_first_node_in_group("upgrade_manager")
	if is_instance_valid(upgrade_manager):
		cooldown *= upgrade_manager.get_cooldown_speed()

	return max(cooldown, 0.3)
