# EventBus.gd - Coração do sistema de comunicação
extends Node

# Sistema de subscrição com prioridades
var _subscribers: Dictionary = {}
var _event_queue: Array[GameEvent] = []
var _processing: bool = false

# --- Subscrição de eventos ---
func subscribe(event_type: int, target: Object, method: String, priority: int = 0) -> void:
	if not _subscribers.has(event_type):
		_subscribers[event_type] = []

	_subscribers[event_type].append({
		"target": target,
		"method": method,
		"priority": priority
	})

	_subscribers[event_type].sort_custom(func(a, b): return a.priority > b.priority)

# --- Emissão de eventos ---
func emit_event(event_type: int, data: Dictionary, source: String) -> void:
	var event = GameEvent.new(event_type, data, source)
	_event_queue.append(event)

	if not _processing:
		_process_queue()

# --- Processamento sequencial da fila de eventos ---
func _process_queue() -> void:
	_processing = true

	while not _event_queue.is_empty():
		var event: GameEvent = _event_queue.pop_front()
		_dispatch_event(event)

	_processing = false

# --- Disparo real do evento para os inscritos ---
func _dispatch_event(event: GameEvent) -> void:
	if not _subscribers.has(event.type):
		return

	for subscriber in _subscribers[event.type]:
		if is_instance_valid(subscriber.target):
			subscriber.target.call(subscriber.method, event)
