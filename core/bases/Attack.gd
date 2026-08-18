class_name Attack


var damage: float = 10.0
var knockback_force: float = 20.0
var stun_time: float = 0.0
var attack_direction: Vector2 = Vector2.ZERO


# Fórmulas de combate compartidas por los enanos y el personaje central,
# para que todos peguen bajo las mismas reglas de ebriedad/upgrades.
# Los gestores se piden a Services: ya no hace falta pasar un nodo del árbol
# como contexto solo para poder buscarlos.

static func modificador_ebriedad() -> float:
	var game_manager: GameManager = Services.game_manager
	if not is_instance_valid(game_manager):
		return 1.0 # siempre retorna 1 por defecto (seguro)
	# La fórmula por zonas (y el bono por encima de 100) vive en DrunkenessManager
	return game_manager.get_drunkenness_multiplier()


static func modificador_upgrades() -> float:
	var upgrade_manager: UpgradeManager = Services.upgrades
	if not is_instance_valid(upgrade_manager):
		return 0.0
	return upgrade_manager.get_damage_modifier()


static func danio_final(base: float) -> float:
	var danio: float = base * modificador_ebriedad() * (1.0 + modificador_upgrades())
	# Bono permanente de ataque (mejoras persistentes de la tienda)
	if Store.save[Store.DATA.BASE_ATK] != 0:
		danio += base * Store.save[Store.DATA.BASE_ATK] / 10
	return danio


#Cooldown final, +20% de velocidad en rango ebrio, límite mínimo 0.3s
static func cooldown_final(base: float) -> float:
	var cooldown: float = base
	var game_manager: GameManager = Services.game_manager
	if is_instance_valid(game_manager) and game_manager.get_drunkenness() > DrunkenessManager.ZONA_EBRIA:
		cooldown *= 0.8

	var upgrade_manager: UpgradeManager = Services.upgrades
	if is_instance_valid(upgrade_manager):
		cooldown *= upgrade_manager.get_cooldown_speed()

	# Bono permanente de velocidad de ataque (mejoras persistentes de la tienda)
	if Store.save[Store.DATA.BASE_ATK_SP] > 0:
		cooldown *= pow(0.9, Store.save[Store.DATA.BASE_ATK_SP])

	return max(cooldown, 0.3)
