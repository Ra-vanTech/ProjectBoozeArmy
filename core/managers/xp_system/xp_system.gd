class_name XPSystem
extends Node

signal xp_gained(current_xp: int, required_xp: int)
signal level_up(new_level: int)

var current_xp: int = 0
var current_level: int = 1
const MAX_LEVEL: int = 10

#formula para la experiencia 
func _xp_for_level(level: int) -> int:
    return roundi(10.0 * pow(1.2, level - 1))


func add_xp(amount: int) -> void:
    if current_level >= MAX_LEVEL:
        return

    current_xp += amount
    var required: int = _xp_for_level(current_level)

    # Capturamos XP ganada en el HUD 
    xp_gained.emit(current_xp, required)
    print("[XPSystem] XP : ", current_xp, " / ", required, " | Nivel: ", current_level)

    #Verificar si se paso el nivel 
    if current_xp >= required:
        current_xp -= required
        current_level += 1
        print("[XPSystem] Lvel up - nivel :", current_level)
        level_up.emit(current_level)
    
    # Actualizamos XP en HUD de nuevo
    if current_level < MAX_LEVEL:
        xp_gained.emit(current_xp, _xp_for_level(current_level))
