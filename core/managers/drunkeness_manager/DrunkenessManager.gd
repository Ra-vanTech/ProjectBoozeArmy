class_name DrunkenessManager
extends Node

#señal para ebriedad
signal sobriety_critical_changed(is_critical: bool)
signal drunkeness_changes(change)

# Umbrales de zona compartidos por daño (EnanoBase), cámara y UI para que
# todos los sistemas lean la misma definición de "sobrio" y "ebrio"
const ZONA_SOBRIA: int = 30
const ZONA_EBRIA: int = 70

@export var starting_drunkeness: int = 50
@export var max_drunkeness: int = 100

#acumula stacks de +1 de ebriedad/s [upgrades]
var drunkeness_per_second: int = -1
var drunkeness: int:
	set(input):
		var previous = drunkeness
		drunkeness = clamp(input, 0, max_drunkeness)
		drunkeness_changes.emit(drunkeness)

		#Compara si el estado "critico" cambió respectoel frame anterior.
		if previous == 0 and drunkeness != 0:
			sobriety_critical_changed.emit(false) # Deja de estar en estado crítico
		elif previous != 0 and drunkeness == 0:
			sobriety_critical_changed.emit(true) # Cambia a estado crítico
var timer: Timer


func _ready() -> void:
	max_drunkeness += Store.save[Store.DATA.MAX_DRUNKENNESS] * 10
	print(max_drunkeness)
	drunkeness = starting_drunkeness
	timer = Timer.new()
	timer.wait_time = 1.0
	timer.one_shot = false
	add_child(timer)
	timer.timeout.connect(_tick)
	timer.start()

	var upgrades_manager: UpgradeManager = get_tree().get_first_node_in_group("upgrade_manager")
	if is_instance_valid(upgrades_manager):
		upgrades_manager.upgrade_applied.connect(_on_upgrade_applied)


func calculate_damage_multiplier() -> float:
	if drunkeness <= 30:
		return 0.7
	elif drunkeness <= 70:
		return 1.0
	elif drunkeness <= 100:
		return 1.3
	else:
		# permite crecimiento de daño adicional
		# no es un bono tan grande, según mi calculadora una ebriedad de 1000 solo daría un bono adicional de 0.54
		# Volví a hacer el cálculo y no sé qué hice pero me da algo totalmente diferente
		return 1.3 + pow(drunkeness - 100, 0.25) / 10.0


func _tick() -> void:
	drunkeness += drunkeness_per_second


func _on_upgrade_applied(type: UpgradeManager.UpgradeType) -> void:
	if type == UpgradeManager.UpgradeType.SOBRIETY_REGEN:
		# La mejora "reduce la caída de ebriedad", como máximo la detiene (0).
		# Sin el tope, 2+ stacks volvían la tasa positiva y la ebriedad subía
		# sola al máximo para siempre, anulando el sistema de riesgo.
		drunkeness_per_second = mini(drunkeness_per_second + 1, 0)
	if type == UpgradeManager.UpgradeType.MAX_DRUNKENNESS:
		max_drunkeness *= 1.1
