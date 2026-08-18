class_name EnanoGuerrero
extends EnanoBase


# solo cambia el tiempo de ataque, lo demas se hereda de Enano base 
func _ready() -> void:
	cooldown_base = 1.2
	super._ready()