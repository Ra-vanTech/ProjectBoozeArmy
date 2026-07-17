extends CanvasLayer

signal purchase_done

const max_levels: Dictionary = {
	Store.DATA.MAX_LVL: 0,
	Store.DATA.STARTING_DWARVES: 10,
	Store.DATA.DMG_MAX_LVL: 0,
	Store.DATA.ATK_SPEED_MAX_LVL: 100,
	Store.DATA.DWARF_LIMIT_MAX_LVL: 0,
	Store.DATA.DRUNKENNESS_MAX_LVL: 10,
	Store.DATA.ENEMY_HP_REDUCTION_MAX_LVL: 20,
}

@onready var player_anchor: HBoxContainer = $ColorRect/CenterContainer/VBoxContainer/Panel/Jugador/Container
@onready var upgrade_anchor: HBoxContainer = $ColorRect/CenterContainer/VBoxContainer/Panel/Niveles/Container
@onready var gold_container: Label = $ColorRect/CenterContainer/VBoxContainer/Gold


func _ready() -> void:
	$TransitionScreen/AnimationPlayer.play("fade_out")
	gold_container.text = "Oro: " + str(Store.save[Store.DATA.GOLD])
	create_card(player_anchor, Store.DATA.MAX_LVL, "Nivel máximo", "Incrementa el nivel máximo del jugador", 500, 1.1)
	create_card(player_anchor, Store.DATA.STARTING_DWARVES, "Enanos iniciales", "Más enanos vienen a ayudarte", 2000, 1.5)

	create_card(upgrade_anchor, Store.DATA.DMG_MAX_LVL, "Daño máximo", "Los enanos atacan con más fuerza", 1000, 1.2)
	create_card(upgrade_anchor, Store.DATA.ATK_SPEED_MAX_LVL, "Velocidad de ataque", "Los enanos atacan más rápido", 1000, 1.2)
	create_card(upgrade_anchor, Store.DATA.DWARF_LIMIT_MAX_LVL, "Enanos de apoyo", "Más enanos están dispuesto a unirse a ti", 2000, 1.3)
	# for thingy in UpgradeManager.UpgradeType:
	# 	print(thingy)
	# pass


# es como hacer html desde js puro, me cae mal
# se me hace más fácil que hacer cada cuadro individualmente
func create_card(anchor: HBoxContainer, store_idx: int, _title: String, _description: String, _cost: int, cost_increase: float) -> void:
	var cost_stored: StoredPrice = StoredPrice.new()
	cost_stored.cost = _cost

	var bg: PanelContainer = PanelContainer.new()
	bg.custom_minimum_size = Vector2(200, -1)

	var center_container: CenterContainer = CenterContainer.new()

	var container: VBoxContainer = VBoxContainer.new()
	container.custom_maximum_size = Vector2(150, -1)
	container.add_theme_constant_override("separation", 15)
	container.alignment = BoxContainer.ALIGNMENT_CENTER

	var title: Label = Label.new()
	title.text = _title
	title.autowrap_mode = TextServer.AUTOWRAP_WORD

	var description: Label = Label.new()
	description.text = _description
	description.autowrap_mode = TextServer.AUTOWRAP_WORD

	var level_display: Label = Label.new()
	level_display.text = "Nivel actual: " + str(Store.save[store_idx])

	var cost: Button = Button.new()
	# Por alguna razón el precio solo se actualiza una vez

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
		cost_stored.cost *= cost_increase
		cost.text = "Comprar: " + _format_price(cost_stored.cost)
		level_display.text = "Nivel actual: " + str(Store.save[store_idx])
		purchase_done.emit()
		# check_availability.call()

	cost.text = "Comprar: " + _format_price(cost_stored.cost)
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
