class_name EnanoCervecero extends EnanoBase

const EBRIEDAD_SEGUNDO: float = 2.0

@onready var timer_ebriedad: Timer = $TimerEbriedad

func _ready() -> void:
	timer_ebriedad.timeout.connect(_generar_ebriedad)
	super._ready()


# MOCKUP para simular el estado de ebriedad en el enano
func _generar_ebriedad() -> void:
	print("[EnanoCervecero] Genera %.1f ebriedad (MOCKUP)" % EBRIEDAD_SEGUNDO)
