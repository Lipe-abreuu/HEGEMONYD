# src/core/events/EventTypes.gd
extends Node
class_name EventTypes

enum Type {
# Eventos de Jogo
	GAME_STARTED,

# Eventos de Tempo (NOVOS e existentes)
	TIME_ADVANCE_DAY,
	TIME_PAUSE,
	TIME_RESUME,
	TIME_PAUSED,
	TIME_RESUMED,
	DAY_PASSED, # Renomeado de DAY_PASSED para consistência
	PHASE_CHANGED,
	MANDATORY_EVENT,

# Eventos de Reformas
	REFORM_INITIATED,
	REFORM_COMPLETED,
	REFORM_FAILED,

# Eventos Políticos
	FACTION_LOYALTY_CHANGED,
	COALITION_STABILITY_CHANGED,

# Eventos Econômicos
	RESOURCE_CHANGED,

# Eventos de UI
	POPUP_REQUESTED,
	NOTIFICATION_ADDED
}
