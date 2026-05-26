class_name StateMachine
extends Node

@export var initial_state: State

var current_state: State
var states: Dictionary = { }


func _ready() -> void:
	for state in get_children():
		if state is State:
			print(state.name)
			states[state.name.to_lower()] = state
			state.state_machine = self
	if initial_state:
		change_state(initial_state.name.to_lower())


func tick(delta: float):
	if current_state:
		current_state.tick(delta)


func phys_tick(delta: float):
	if current_state:
		current_state.phys_tick(delta)


func handle_input() -> void:
	if current_state:
		current_state.handle_input()


func change_state(new_state: String) -> void:
	if current_state:
		current_state.exit()

	current_state = states.get(new_state.to_lower())

	if current_state:
		current_state.enter()
