class_name Player
extends CharacterBody3D

@export var health := 100.0
@export var COINS_DROPPED := 0

var timer: Timer

@onready var drunkeness: DrunkenessMeter = get_tree().get_first_node_in_group("drunkeness")
@onready var state_machine: StateMachine = %StateMachine
@onready var input_component: InputComponent = %InputComponent
@onready var hit_box_component: HitBoxComponent = %HitBoxComponent
@onready var dwarf_system: DwarfSystem = %DwarfContainer


func _ready() -> void:
	Engine.time_scale = 1
	timer = Timer.new()
	timer.wait_time = 1.0
	timer.one_shot = false
	add_child(timer)
	timer.timeout.connect(sobriety_damage)
	hit_box_component.health_component.health = health
	hit_box_component.health_component.COINS_DROPPED_DEFAULT = COINS_DROPPED

	if is_instance_valid(drunkeness):
		drunkeness.sobriety_critical_changed.connect(_on_sobriety_critical_changed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	state_machine.tick(delta)

	if input_component.wants_spawn:
		dwarf_system.agregar_enano()

	if input_component.wants_despawn:
		dwarf_system.eliminar_enano()

	if input_component.has_quit:
		state_machine.change_state("PausedState")


func _on_sobriety_critical_changed(is_critical: bool) -> void:
	if is_critical:
		timer.start()
	else:
		timer.stop()
		

func sobriety_damage() -> void:
	var chance = randi_range(0, 2)
	if chance == 1:
		print("Enano muere por sobrio")
		damage()


func damage():
	dwarf_system.eliminar_enano()


func _on_health_component_has_died() -> void:
	state_machine.change_state("DeadState")


func _on_pause_screen_overlay_game_resumed() -> void:
	state_machine.change_state("IdleState")
