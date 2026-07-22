class_name EnanoCervecero
extends EnanoBase

const EBRIEDAD_SEGUNDO: int = 2

@onready var timer_ebriedad: Timer = $TimerEbriedad


func _ready() -> void:
	timer_ebriedad.wait_time = EBRIEDAD_SEGUNDO
	timer_ebriedad.timeout.connect(_generar_ebriedad)
	super._ready()


func _generar_ebriedad() -> void:
	var game_manager: GameManager = get_tree().get_first_node_in_group("game_manager")
	if not is_instance_valid(game_manager):
		push_error("[EnanoCervecero] No se encontro el gestor de juego en el árbol")
		return
	game_manager.add_drunkeness(EBRIEDAD_SEGUNDO)
	# Texto pequeño sobre el cervecero para que se vea de dónde sale la ebriedad
	CombatVFX.floating_text(self, global_position, "+%d" % EBRIEDAD_SEGUNDO, Color(0.4, 0.9, 0.3), 72)
