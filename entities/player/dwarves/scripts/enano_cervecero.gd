class_name EnanoCervecero
extends EnanoBase

const EBRIEDAD_SEGUNDO: int = 2

@onready var timer_ebriedad: Timer = $TimerEbriedad


func _ready() -> void:
	timer_ebriedad.wait_time = EBRIEDAD_SEGUNDO
	timer_ebriedad.timeout.connect(_generar_ebriedad)
	super._ready()


func _generar_ebriedad() -> void:
	var drunkeness_meter: DrunkenessManager = get_tree().get_first_node_in_group("game_manager").drunkeness_manager
	if not is_instance_valid(drunkeness_meter):
		push_error("[EnanoCervecero] No se encontro DrunkenessMeter en el árbol")
		return
	drunkeness_meter.drunkeness += EBRIEDAD_SEGUNDO
	# Texto pequeño sobre el cervecero para que se vea de dónde sale la ebriedad
	CombatVFX.floating_text(self, global_position, "+%d" % EBRIEDAD_SEGUNDO, Color(0.4, 0.9, 0.3), 72)
