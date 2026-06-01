class_name DwarfIdleState
extends State

@onready var dwarf: EnanoBase = owner as EnanoBase

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func tick(_delta: float) -> void:
	# Si la lista de enemigos ya no está vacía, pasamos al ataque
	if not dwarf.enemies_in_range.is_empty():
		state_machine.change_state("DwarfAttackState")