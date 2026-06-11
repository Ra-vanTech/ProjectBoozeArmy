class_name DrunkenessMeter
extends Label

@export var starting_drunkeness: int = 50
@export var max_drunkeness: int = 100

var drunkeness: int:
	set(input):
		drunkeness = clamp(input, 0, max_drunkeness)
		text = "Ebriedad: " + str(drunkeness)
		modulate = Color.RED.lerp(Color.WHITE, float(drunkeness) / max_drunkeness)
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
