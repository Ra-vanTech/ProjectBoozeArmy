extends CanvasLayer

signal purchase_done

const max_levels: Dictionary = {
	#
	Store.DATA.MAX_LVL: 0,
	Store.DATA.STARTING_DWARVES: 10,
	Store.DATA.BASE_ATK: 50,
	Store.DATA.BASE_ATK_SP: 10,
	Store.DATA.BASE_SPD: 10,
	Store.DATA.MAX_DRUNKENNESS: 900,
	Store.DATA.XP_BONUS: 100,
	Store.DATA.COINS_BONUS: 0,
	#
	Store.DATA.DMG_MAX_LVL: 0,
	Store.DATA.ATK_SPEED_MAX_LVL: 100,
	Store.DATA.DWARF_LIMIT_MAX_LVL: 0,
	Store.DATA.DRUNKENNESS_MAX_LVL: 10,
	Store.DATA.ENEMY_HP_REDUCTION_MAX_LVL: 20,
	Store.DATA.MAX_DRUNKENNESS_MAX_LVL: 0,
	Store.DATA.XP_BONUS_MAX_LVL: 0,
	Store.DATA.COINS_BONUS_MAX_LVL: 0,
}

@onready var player_anchor: HBoxContainer = $ColorRect/CenterContainer/VBoxContainer/Panel/Jugador/ScrollContainer/Container
@onready var upgrade_anchor: HBoxContainer = $ColorRect/CenterContainer/VBoxContainer/Panel/Niveles/ScrollContainer/Container
@onready var gold_container: Label = $ColorRect/CenterContainer/VBoxContainer/Gold


# TODO: Añadir mejoras de ebriedad máxima y ganancia de oro y experiencia
func _ready() -> void:
	$TransitionScreen/AnimationPlayer.play("fade_out")
	gold_container.text = "Oro: " + str(Store.save[Store.DATA.GOLD])

	create_card(player_anchor, Store.DATA.MAX_LVL, 500, 1.1)
	create_card(player_anchor, Store.DATA.STARTING_DWARVES, 2000, 2.1)
	create_card(player_anchor, Store.DATA.BASE_ATK, 1500, 1.5)
	create_card(player_anchor, Store.DATA.BASE_ATK_SP, 1250, 1.3)
	create_card(player_anchor, Store.DATA.BASE_SPD, 1250, 1.5)
	create_card(player_anchor, Store.DATA.MAX_DRUNKENNESS, 3000, 1.5)
	create_card(player_anchor, Store.DATA.XP_BONUS, 3000, 1.5)
	create_card(player_anchor, Store.DATA.COINS_BONUS, 750, 1.3)

	create_card(upgrade_anchor, Store.DATA.DMG_MAX_LVL, 1000, 1.2)
	create_card(upgrade_anchor, Store.DATA.ATK_SPEED_MAX_LVL, 1000, 1.2)
	create_card(upgrade_anchor, Store.DATA.DWARF_LIMIT_MAX_LVL, 2000, 1.3)
	create_card(upgrade_anchor, Store.DATA.DRUNKENNESS_MAX_LVL, 5000, 2)
	create_card(upgrade_anchor, Store.DATA.ENEMY_HP_REDUCTION_MAX_LVL, 3000, 1.5)
	create_card(upgrade_anchor, Store.DATA.MAX_DRUNKENNESS_MAX_LVL, 2500, 1.5)
	create_card(upgrade_anchor, Store.DATA.XP_BONUS_MAX_LVL, 2500, 1.5)
	create_card(upgrade_anchor, Store.DATA.COINS_BONUS_MAX_LVL, 2500, 1.5)
	# for thingy in UpgradeManager.UpgradeType:
	# 	print(thingy)
	# pass


# es como hacer html desde js puro, me cae mal
# se me hace más fácil que hacer cada cuadro individualmente
func create_card(anchor: HBoxContainer, store_idx: int, _cost: int, cost_increase: float) -> void:
	var cost_stored: StoredPrice = StoredPrice.new()
	cost_stored.cost = _cost

	var bg: PanelContainer = PanelContainer.new()
	bg.custom_minimum_size = Vector2(200, -1)

	var center_container: CenterContainer = CenterContainer.new()

	var container: VBoxContainer = VBoxContainer.new()
	container.custom_minimum_size = Vector2(150, -1)
	container.add_theme_constant_override("separation", 15)
	container.alignment = BoxContainer.ALIGNMENT_CENTER

	var title: Label = Label.new()
	title.text = Descriptions.desc[store_idx].name
	title.autowrap_mode = TextServer.AUTOWRAP_WORD

	var description: Label = Label.new()
	description.text = Descriptions.desc[store_idx].desc
	description.autowrap_mode = TextServer.AUTOWRAP_WORD

	var level_display: Label = Label.new()
	if max_levels[store_idx] == 0:
		level_display.text = "Nivel actual: " + str(Store.save[store_idx]) + " / ∞" # Poner símbolo de infinito cuando lo encuentre
	else:
		level_display.text = "Nivel actual: " + str(Store.save[store_idx]) + " / " + str(max_levels[store_idx])

	var cost: Button = Button.new()
	# Por alguna razón el precio solo se actualiza una vez
	var update_price = func() -> void:
		# Se usa una variable temporal pq si no creo que hace mal el cálculo del precio
		var temp_exp = Store.save[store_idx] - Store.STARTING_VAL[store_idx]
		var temp = _cost * pow(cost_increase, temp_exp)
		cost_stored.cost = temp
		cost.text = "Comprar: " + _format_price(cost_stored.cost)

	var check_availability = func() -> void:
		if Store.save[Store.DATA.GOLD] < cost_stored.cost:
			cost.disabled = true
		if Store.save[store_idx] >= max_levels[store_idx] and max_levels[store_idx] != 0:
			cost.disabled = true
			cost.text = "MAX"
	purchase_done.connect(check_availability)

	var purchase = func() -> void:
		Store.save[Store.DATA.GOLD] -= cost_stored.cost
		Store.save_data()
		gold_container.text = str(Store.save[Store.DATA.GOLD])
		Store.save[store_idx] += 1
		Descriptions.desc[store_idx] = Store.save[store_idx]
		update_price.call()
		if max_levels[store_idx] == 0:
			level_display.text = "Nivel actual: " + str(Store.save[store_idx]) + " / ∞" # Poner símbolo de infinito cuando lo encuentre
		else:
			level_display.text = "Nivel actual: " + str(Store.save[store_idx]) + " / " + str(max_levels[store_idx])
		purchase_done.emit()
		# check_availability.call()

	update_price.call()
	check_availability.call()
	cost.pressed.connect(purchase)

	container.add_child(title)
	container.add_child(description)
	container.add_child(level_display)
	container.add_child(cost)

	center_container.add_child(container)
	bg.add_child(center_container)

	anchor.add_child(bg)
	pass


func _format_price(price: int) -> String:
	const preffix: String = "$"
	if price >= 1000:
		return preffix + str(price / 1000 + snapped((price % 1000) / 1000.0, 0.01)) + "k"
	return preffix + str(price)


func _on_timer_timeout() -> void:
	get_tree().change_scene_to_file("res://ui/menu_screen/main_menu.tscn")


func _on_button_pressed() -> void:
	$TransitionScreen.show()
	$TransitionScreen/AnimationPlayer.play("fade_in")
	$TransitionScreen/Timer.start()


# Por alguna razón, las funciones lambda en gdscript no pueden modificar variables externas a pesar
# de que sí pueda acceder a ellas, así que se le tienen que dar valores que se pasan por referencia
# (arreglos, diccionarios, objetos, clases, etc...)
class StoredPrice:
	var cost: int
