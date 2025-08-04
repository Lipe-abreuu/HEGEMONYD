# res://game/src/game/systems/time/TimeSystem.gd
# Sistema de tempo e fases do jogo, com ciclo de Manhã, Tarde e Noite.
extends Node
class_name TimeSystem

# Enum para as fases do dia
enum DayPhase { MORNING, AFTERNOON, NIGHT }

# --- SINAIS ---
signal day_phase_changed(new_phase: DayPhase)
signal day_advanced(new_date: Dictionary)
signal historical_phase_changed(new_phase: int)

# --- REFERÊNCIAS E ESTADO ---
var game_data: GameData
var is_paused: bool = true

var current_day_phase: DayPhase = DayPhase.MORNING
var current_historical_phase: int = -1 # Força a primeira atualização

var phase_timer: Timer

# Modificadores de fase. Usamos 'var' em vez de 'const' para evitar erros de compilação do GDScript.
# Os nomes das fases agora correspondem exatamente ao enum em Calendar.gd.
var PHASE_MODIFIERS: Dictionary = {
									  Calendar.HistoricalPhase.HONEYMOON: {
										  "political_capital_regen": 1.2,
										  "threat_aggression": 0.6,
										  "popular_enthusiasm": 1.3,
										  "economic_stability": 1.1
									  },
									  Calendar.HistoricalPhase.POLARIZATION: {
										  "political_capital_regen": 1.0,
										  "threat_aggression": 1.0,
										  "popular_enthusiasm": 1.0,
										  "economic_stability": 1.0
									  },
									  Calendar.HistoricalPhase.CRISIS: {
										  "political_capital_regen": 0.8,
										  "threat_aggression": 1.5,
										  "popular_enthusiasm": 0.7,
										  "economic_stability": 0.8
									  },
									  Calendar.HistoricalPhase.ENDGAME: {
										  "political_capital_regen": 0.6,
										  "threat_aggression": 2.0,
										  "popular_enthusiasm": 0.5,
										  "economic_stability": 0.5
									  }
								  }

# === INICIALIZAÇÃO ===
func _ready() -> void:
	# Configuração do Timer via código para garantir controle total
	phase_timer = Timer.new()
	phase_timer.name = "PhaseTimer"
	phase_timer.wait_time = 2.0 # Tempo para cada fase do dia (ajustável)
	phase_timer.one_shot = false
	phase_timer.timeout.connect(_on_phase_timer_timeout)
	add_child(phase_timer)

	# Inscrição nos eventos de controle do jogo. A verificação 'is_connected' foi removida.
	if EventBus:
		EventBus.subscribe(EventTypes.Type.TIME_PAUSE, self, "pause_time")
		EventBus.subscribe(EventTypes.Type.TIME_RESUME, self, "resume_time")
		EventBus.subscribe(EventTypes.Type.GAME_STARTED, self, "_on_game_started")

# === CONTROLE DE TEMPO ===
func pause_time(_event = null) -> void:
	if is_paused: return
	is_paused = true
	phase_timer.stop()
	print("TimeSystem: Pausado")
	if EventBus:
		EventBus.emit_event(EventTypes.Type.TIME_PAUSED, {}, "TimeSystem")

func resume_time(_event = null) -> void:
	if not game_data:
		push_warning("TimeSystem: Tentativa de retomar o tempo sem GameData. Ignorando.")
		return
	if not is_paused: return
	is_paused = false
	phase_timer.start()
	print("TimeSystem: Retomado")
	if EventBus:
		EventBus.emit_event(EventTypes.Type.TIME_RESUMED, {}, "TimeSystem")

# === LÓGICA DO JOGO ===
func _on_phase_timer_timeout() -> void:
	if is_paused:
		return

	# Avança para a próxima fase do dia
	current_day_phase = DayPhase.values()[(current_day_phase + 1) % DayPhase.size()]
	day_phase_changed.emit(current_day_phase)
	print("TimeSystem: Nova fase do dia - ", DayPhase.keys()[current_day_phase])

	# Se a nova fase for a Manhã, um novo dia começou
	if current_day_phase == DayPhase.MORNING:
		_advance_full_day()

func _advance_full_day() -> void:
	if not game_data:
		push_error("TimeSystem: GameData não encontrado para avançar o dia.")
		pause_time()
		return

	# 1. Avançar a data no GameData
	game_data.current_date = Calendar.add_day(game_data.current_date)
	day_advanced.emit(game_data.current_date)
	print("TimeSystem: Dia avançado para ", Calendar.date_to_string(game_data.current_date))

	# 2. Emitir evento de dia passado
	if EventBus:
		EventBus.emit_event(EventTypes.Type.DAY_PASSED, {"date": game_data.current_date}, "TimeSystem")

	# 3. Verificar e emitir evento obrigatório (APENAS NA MANHÃ)
	var event_id = Calendar.is_event_day(game_data.current_date)
	if event_id != "":
		print("TimeSystem: Evento obrigatório disparado: ", event_id)
		if EventBus:
			EventBus.emit_event(EventTypes.Type.MANDATORY_EVENT, {"id": event_id}, "TimeSystem")

	# 4. Verificar mudança de fase histórica
	_check_for_historical_phase_change()

func _check_for_historical_phase_change() -> void:
	var new_historical_phase = Calendar.get_historical_phase(game_data.current_date)

	if new_historical_phase != current_historical_phase:
		var old_phase = current_historical_phase
		current_historical_phase = new_historical_phase
		game_data.historical_phase = new_historical_phase

		if PHASE_MODIFIERS.has(new_historical_phase):
			game_data.phase_modifiers = PHASE_MODIFIERS[new_historical_phase]
		else:
			game_data.phase_modifiers = {}

		historical_phase_changed.emit(new_historical_phase)
		print("TimeSystem: Fase histórica mudou para ", Calendar.get_phase_name(new_historical_phase))

		if EventBus:
			EventBus.emit_event(EventTypes.Type.PHASE_CHANGED, {
				"old_phase": old_phase,
				"new_phase": new_historical_phase,
				"modifiers": game_data.phase_modifiers
			}, "TimeSystem")

# === CALLBACKS DO EVENTBUS ===
func _on_game_started(event) -> void:
	if event.data and event.data.has("game_data"):
		game_data = event.data.game_data
		_check_for_historical_phase_change()
		print("TimeSystem: Inicializado com GameData. O jogo começa pausado.")
	else:
		push_error("TimeSystem: Evento GAME_STARTED não continha GameData.")
		pause_time()
