extends CanvasLayer

@onready var player_anchor: HBoxContainer = $ColorRect/CenterContainer/VBoxContainer/Panel/Jugador/Container
@onready var upgrade_anchor: HBoxContainer = $ColorRect/CenterContainer/VBoxContainer/Panel/Niveles/Container
@onready var gold_container: Label = $ColorRect/CenterContainer/VBoxContainer/Gold


func _ready() -> void:
	$TransitionScreen/AnimationPlayer.play("fade_out")
	gold_container.text = "Oro: " + str(Store.save[Store.DATA.GOLD])
	create_card(player_anchor, 1, "Nivel máximo", "Incrementa el nivel máximo del jugador", 500)
	create_card(player_anchor, 2, "Enanos iniciales", "Incrementa los enanos que se tienen al iniciar la partida", 2000)
	for thingy in UpgradeManager.UpgradeType:
		print(thingy)
	pass


func create_card(anchor: HBoxContainer, card_idx: int, _title: String, _description: String, _cost: int) -> void:
	var test = func something() -> void:
		print(_cost)

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

	var cost: Button = Button.new()
	cost.text = "Comprar: " + str(_cost)
	cost.pressed.connect(test)

	container.add_child(title)
	container.add_child(description)
	container.add_child(cost)

	center_container.add_child(container)
	bg.add_child(center_container)

	anchor.add_child(bg)
	pass


func aaa() -> void:
	print("aa")


func _on_timer_timeout() -> void:
	get_tree().change_scene_to_file("res://ui/menu_screen/main_menu.tscn")


func _on_button_pressed() -> void:
	$TransitionScreen.show()
	$TransitionScreen/AnimationPlayer.play("fade_in")
	$TransitionScreen/Timer.start()
