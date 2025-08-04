# res://game/src/game/systems/time/DayPhases.gd
# Sistema de fases do dia (manhã, tarde, noite) para o TimeSystem
# Permite ações específicas em diferentes momentos do dia

extends Node
class_name DayPhases

enum Phase { MORNING, AFTERNOON, NIGHT }

static var current_day_phase: int = Phase.MORNING

# Avança para a próxima fase do dia
static func advance_phase() -> int:
    current_day_phase = (current_day_phase + 1) % 3
    return current_day_phase

# Retorna o nome da fase atual
static func get_phase_name(phase: int = current_day_phase) -> String:
    match phase:
        Phase.MORNING:
            return "Manhã"
        Phase.AFTERNOON:
            return "Tarde"
        Phase.NIGHT:
            return "Noite"
        _:
            return "Desconhecida"

# Retorna modificadores específicos da fase do dia
static func get_phase_modifiers(phase: int = current_day_phase) -> Dictionary:
    match phase:
        Phase.MORNING:
            return {"productivity": 1.1, "political_activity": 1.2}
        Phase.AFTERNOON:
            return {"productivity": 1.0, "political_activity": 1.0}
        Phase.NIGHT:
            return {"productivity": 0.8, "political_activity": 0.7}
        _:
            return {}

# Reseta para manhã (usado quando um novo dia começa)
static func reset_to_morning():
    current_day_phase = Phase.MORNING
