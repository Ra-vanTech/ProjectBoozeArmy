class_name DrunkenessMeter
extends Label


#señal para ebriedad 
signal sobriety_critical_changed(is_critical: bool)

@export var starting_drunkeness: int = 50
@export var max_drunkeness: int = 100


var drunkeness: int:
	set(input):
		var previous: int = drunkeness
		drunkeness = clamp(input, 0, max_drunkeness)
		text = "Ebriedad: " + str(drunkeness)
		modulate = Color.RED.lerp(Color.WHITE, float(drunkeness) / max_drunkeness)

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
	timer.timeout.connect(substract_drunkeness)
	timer.start()


func substract_drunkeness() -> void:
	drunkeness -= 1
