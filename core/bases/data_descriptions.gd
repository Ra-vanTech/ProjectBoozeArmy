class_name Descriptions

static var desc: Dictionary = {
	Store.DATA.DMG_MAX_LVL: item("Resaca (no sé)", "Los enanos hacen más daño (+20%)", Store.save[Store.DATA.DMG_MAX_LVL]),
	Store.DATA.ATK_SPEED_MAX_LVL: item("Agilidad", "Los enanos atacan más rápido (+15%)", Store.save[Store.DATA.ATK_SPEED_MAX_LVL]),
	Store.DATA.DWARF_LIMIT_MAX_LVL: item("Compañía", "Un enano se une a tu causa", Store.save[Store.DATA.DWARF_LIMIT_MAX_LVL]),
	Store.DATA.DRUNKENNESS_MAX_LVL: item("Fiesta", "La ebriedad por segundo aumenta (+1/s)", Store.save[Store.DATA.DRUNKENNESS_MAX_LVL]),
	Store.DATA.ENEMY_HP_REDUCTION_MAX_LVL: item("Sangrado", "La salud máxima de los enemigos se reduce", Store.save[Store.DATA.ENEMY_HP_REDUCTION_MAX_LVL]),
	Store.DATA.MAX_DRUNKENNESS_MAX_LVL: item("Resistencia", "La ebriedad máxima incrementa (+10%)", Store.save[Store.DATA.MAX_DRUNKENNESS_MAX_LVL]),
	Store.DATA.XP_BONUS_MAX_LVL: item("Intelecto", "Se obtiene más experiencia de los enemigos (+10%)", Store.save[Store.DATA.XP_BONUS_MAX_LVL]),
	Store.DATA.COINS_BONUS_MAX_LVL: item("Saqueo", "Se obtiene más oro de los enemigos (+10%)", Store.save[Store.DATA.COINS_BONUS]),
	#
	# Las mejoras del jugador no necesitan que se les señale el nivel máximo, ya que solo es para usarse en el gestor de mejoras
	Store.DATA.MAX_LVL: item("Sabiduría", "Incrementa el nivel máximo", 0),
	Store.DATA.STARTING_DWARVES: item("Fama", "Más enanos se te unen al iniciar una partida", 0),
	Store.DATA.BASE_ATK: item("Fortaleza", "Los enanos atacan con más fuerza (+10%)", 0),
	Store.DATA.BASE_ATK_SP: item("Furia", "Los enanos atacan más rápido (+10%)", 0),
	Store.DATA.BASE_SPD: item("Agilidad", "Aumenta la velocidad de movimiento del jugador (+1u/s)", 0),
	Store.DATA.MAX_DRUNKENNESS: item("Alcoholismo", "Aumenta la ebriedad máxima del jugador (+10)", 0),
	Store.DATA.XP_BONUS: item("Conocimiento", "Incrementa la experiencia obtenida (+1)", 0),
	Store.DATA.COINS_BONUS: item("Codicia", "Incrementa el oro obtenido (+5)", 0),
}


static func item(upgrade_name: String, description: String, max_lvl: int) -> Dictionary:
	return { "name": upgrade_name, "desc": description, "max_lvl": max_lvl }
