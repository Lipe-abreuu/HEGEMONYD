# TimeSystem.gd - Controla o calendário, a velocidade e as fases do jogo.
extends Node

# --- Variáveis do Sistema ---
var current_date: Dictionary = {"day": 1, "month": 11, "year": 1970}
var days_passed_total: int = 0
var game_speed: float = 1.0 # 1.0 = 1 segundo por dia
var is_paused: bool = true

var day_timer: Timer

# --- Fases Históricas ---
enum HistoricalPhase {
	HONEYMOON,
	POLARIZATION,
	CRISIS,
	ENDGAME
}
var current_phase: HistoricalPhase = HistoricalPhase.HONEYMOON

func _ready() -> void:
	day_timer = Timer.new()
	day_timer.wait_time = game_speed
	day_timer.one_shot = false
	day_timer.timeout.connect(_on_day_timer_timeout)
	add_child(day_timer)
	
	print("TimeSystem inicializado.")

# --- Controles do Jogo ---
func start_time():
	is_paused = false
	day_timer.start()
	print("Tempo iniciado.")

func pause_time():
	is_paused = true
	day_timer.stop()
	print("Tempo pausado.")

func set_speed(new_speed: float):
	game_speed = max(0.1, new_speed)
	day_timer.wait_time = game_speed
	print("Velocidade do jogo alterada para: " + str(new_speed))

# --- Lógica Principal ---

func _on_day_timer_timeout():
	if is_paused:
		return
	advance_day()

func advance_day():
	current_date.day += 1
	days_passed_total += 1
	
	# --- MUDANÇA AQUI ---
	# Usa nossa função interna correta em vez da que não existe.
	var days_in_month = _get_days_in_month(current_date.year, current_date.month)
	# --- FIM DA MUDANÇA ---
	
	if current_date.day > days_in_month:
		current_date.day = 1
		current_date.month += 1
		if current_date.month > 12:
			current_date.month = 1
			current_date.year += 1
		
	EventBus.emit_event(EventBus.EventType.DAY_PASSED, {
		"new_date": current_date,
		"total_days": days_passed_total
	}, "TimeSystem")

	_check_phase_transition()

# --- MUDANÇA AQUI ---
# Adicionamos esta função auxiliar para calcular os dias no mês corretamente.
func _get_days_in_month(year: int, month: int) -> int:
	match month:
		4, 6, 9, 11:
			return 30
		2: # Fevereiro
			# Lógica do ano bissexto
			if (year % 4 == 0 and year % 100 != 0) or (year % 400 == 0):
				return 29 # Ano bissexto
			else:
				return 28 # Ano comum
		_:
			return 31 # Todos os outros meses
# --- FIM DA MUDANÇA ---

func _check_phase_transition():
	match current_phase:
		HistoricalPhase.HONEYMOON:
			if current_date.year == 1971 and current_date.month >= 7:
				_transition_to_phase(HistoricalPhase.POLARIZATION)
		HistoricalPhase.POLARIZATION:
			if current_date.year == 1972 and current_date.month >= 11:
				_transition_to_phase(HistoricalPhase.CRISIS)

func _transition_to_phase(new_phase: HistoricalPhase):
	current_phase = new_phase
	EventBus.emit_event(EventBus.EventType.PHASE_CHANGED, {"new_phase": new_phase}, "TimeSystem")
	print("--- FASE HISTÓRICA ALTERADA PARA: " + str(new_phase) + " ---")
