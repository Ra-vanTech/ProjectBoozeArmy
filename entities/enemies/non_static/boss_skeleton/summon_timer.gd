extends Timer

@export var state_machine: StateMachine

func _ready() -> void:
    timeout.connect(_on_timeout)

func _on_timeout() -> void:
    state_machine.change_state("EnemySummonState")