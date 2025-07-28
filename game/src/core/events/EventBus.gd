# EventBus.gd - Coração do sistema de comunicação
extends Node

# Tipos de eventos como enums para type safety
enum EventType {
	# Sistema
	GAME_STARTED,
	DAY_PASSED,
	PHASE_CHANGED,
	
	# Político
	REFORM_INITIATED,
	REFORM_COMPLETED,
	REFORM_FAILED,
	FACTION_LOYALTY_CHANGED,
	COALITION_STABILITY_CHANGED,
	
	# Econômico
	RESOURCE_CHANGED,
	PRODUCTION_UPDATED,
	TRADE_DEAL_PROPOSED,
	ECONOMIC_CRISIS,
	
	# Ameaças
	THREAT_DETECTED,
	THREAT_EXECUTED,
	CIA_ACTION,
	ELITE_REACTION,
	MILITARY_MOVEMENT,
	
	# UI
	REGION_CLICKED,
	MINISTRY_CLICKED,
	POPUP_REQUESTED,
	NOTIFICATION_ADDED
}

# Sistema de subscrição com prioridades
var _subscribers: Dictionary = {}
var _event_queue: Array[GameEvent] = []
var _processing: bool = false

func subscribe(event_type: EventType, target: Object, method: String, priority: int = 0):
	if not _subscribers.has(event_type):
		_subscribers[event_type] = []
	
	_subscribers[event_type].append({
		"target": target,
		"method": method,
		"priority": priority
	})
	
	# Ordenar por prioridade
	_subscribers[event_type].sort_custom(func(a, b): return a.priority > b.priority)

func emit_event(event_type: EventType, data: Dictionary, source: String):
	var event = GameEvent.new(event_type, data, source)
	_event_queue.append(event)
	
	if not _processing:
		_process_queue()

func _process_queue():
	_processing = true
	
	while not _event_queue.is_empty():
		var event: GameEvent = _event_queue.pop_front()
		_dispatch_event(event)
	
	_processing = false

func _dispatch_event(event: GameEvent):
	if not _subscribers.has(event.type):
		return
	
	for subscriber in _subscribers[event.type]:
		if is_instance_valid(subscriber.target):
			subscriber.target.call(subscriber.method, event)
