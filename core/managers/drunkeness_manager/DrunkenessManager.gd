class_name DrunkenessManager
extends Node

#señal para ebriedad
signal sobriety_critical_changed(is_critical: bool)

@export var starting_drunkeness: int = 50
@export var max_drunkeness: int = 100

#acumula stacks de +1 de ebriedad/s [upgrades]
var regen_per_second: int = 0
var drunkeness: int:
	set(input):
		var previous: int = drunkeness
		drunkeness = clamp(input, 0, max_drunkeness)

		#Compara si el estado "critico" cambió respectoel frame anterior.
		var was_critical: bool = previous == 0
		var is_critical: bool = drunkeness == 0
		if was_critical != is_critical:
			sobriety_critical_changed.emit(is_critical)
var timer: Timer


func _ready() -> void:
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


func _tick() -> void:
	drunkeness = drunkeness - 1 + regen_per_second


func _on_upgrade_applied(type: UpgradeManager.UpgradeType) -> void:
	if type == UpgradeManager.UpgradeType.SOBRIETY_REGEN:
		regen_per_second += 1
