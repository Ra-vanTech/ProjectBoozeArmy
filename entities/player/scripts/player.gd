class_name Player
extends CharacterBody3D

var timer: Timer
var _is_dead: bool = false

@onready var drunkeness: DrunkenessManager = get_tree().get_first_node_in_group("game_manager").drunkeness_manager # aquí también es más fácil acceder solo al gestor de estado
@onready var state_machine: StateMachine = %StateMachine
@onready var input_component: InputComponent = %InputComponent
@onready var dwarf_system: DwarfSystem = %DwarfContainer


func _ready() -> void:
	get_tree().paused = false
	timer = Timer.new()
	timer.wait_time = 1.0
	timer.one_shot = false
	add_child(timer)
	timer.timeout.connect(sobriety_damage)
	dwarf_system.ejercito_derrotado.connect(_on_ejercito_derrotado)

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


func sobriety_damage() -> void:
	var chance = randi_range(0, 2)
	if chance == 1:
		damage()


func damage():
	if _is_dead:
		return
	dwarf_system.eliminar_enano()


#Cambia el estado del timer cuando la sobriedad del jugador es critica
func _on_sobriety_critical_changed(is_critical: bool) -> void:
	if is_critical:
		timer.start()
	else:
		timer.stop()
	print("El estado critico del jugador ha cambiado a: ", is_critical)


#estado de muerte
func _on_ejercito_derrotado() -> void:
	_is_dead = true
	state_machine.change_state("DeadState")


func _on_pause_screen_overlay_game_resumed() -> void:
	state_machine.change_state("IdleState")


func _on_pickup_radius_body_entered(body: Node3D) -> void:
	if body.has_method("pickup"):
		body.pickup()
