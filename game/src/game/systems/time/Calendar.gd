# res://game/src/game/systems/time/Calendar.gd
# Sistema de calendário histórico para o jogo A Via Chilena ao Socialismo
# Gerencia datas, fases históricas e eventos obrigatórios baseados na cronologia real

extends Node

# Enumeração das fases históricas do governo Allende
enum HistoricalPhase {
	HONEYMOON,     # nov/70 - dez/71: Lua de mel inicial
	POLARIZATION,  # jan/72 - jul/72: Crescimento da polarização
	CRISIS,        # ago/72 - jun/73: Crise econômica e social
	ENDGAME        # jul/73 - set/73: Preparação para o golpe
}

# Dados dos eventos obrigatórios carregados do JSON
static var mandatory_events: Dictionary = {}
static var events_loaded: bool = false

# === MÉTODOS ESTÁTICOS PRINCIPAIS ===

# Avança um dia na data fornecida, lidando com transbordo de mês/ano
static func add_day(date: Dictionary) -> Dictionary:
	var new_date = date.duplicate()
	new_date.day += 1

	# Verificar transbordo de mês
	var days_in_month = get_days_in_month(new_date.month, new_date.year)
	if new_date.day > days_in_month:
		new_date.day = 1
		new_date.month += 1

		# Verificar transbordo de ano
		if new_date.month > 12:
			new_date.month = 1
			new_date.year += 1

	return new_date

# Retorna a fase histórica baseada na data atual
static func get_historical_phase(date: Dictionary) -> int:
	var year = date.year
	var month = date.month

	# Honeymoon: nov/70 - dez/71
	if year == 1970 and month >= 11:
		return HistoricalPhase.HONEYMOON
	elif year == 1971:
		return HistoricalPhase.HONEYMOON

	# Polarization: jan/72 - jul/72
	elif year == 1972 and month <= 7:
		return HistoricalPhase.POLARIZATION

	# Crisis: ago/72 - jun/73
	elif (year == 1972 and month >= 8) or (year == 1973 and month <= 6):
		return HistoricalPhase.CRISIS

	# Endgame: jul/73 - set/73
	elif year == 1973 and month >= 7:
		return HistoricalPhase.ENDGAME

	# Fallback para datas fora do período
	return HistoricalPhase.HONEYMOON

# Verifica se há evento obrigatório na data especificada
static func is_event_day(date: Dictionary) -> String:
	_load_mandatory_events_if_needed()

	var date_key = "%04d-%02d-%02d" % [date.year, date.month, date.day]

	if mandatory_events.has(date_key):
		return mandatory_events[date_key]

	return ""

# Retorna o nome da fase histórica como string
static func get_phase_name(phase: int) -> String:
	match phase:
		HistoricalPhase.HONEYMOON:
			return "Lua de Mel"
		HistoricalPhase.POLARIZATION:
			return "Polarização"
		HistoricalPhase.CRISIS:
			return "Crise"
		HistoricalPhase.ENDGAME:
			return "Fim de Jogo"
		_:
			return "Desconhecida"

# Retorna modificadores globais para a fase atual
static func get_phase_modifiers(phase: int) -> Dictionary:
	match phase:
		HistoricalPhase.HONEYMOON:
			return {
				"popular_support_modifier": 1.2,
				"economic_stability": 1.1,
				"cia_activity": 0.3,
				"military_loyalty": 1.0
			}
		HistoricalPhase.POLARIZATION:
			return {
				"popular_support_modifier": 1.0,
				"economic_stability": 0.9,
				"cia_activity": 0.6,
				"military_loyalty": 0.9
			}
		HistoricalPhase.CRISIS:
			return {
				"popular_support_modifier": 0.8,
				"economic_stability": 0.7,
				"cia_activity": 0.9,
				"military_loyalty": 0.7
			}
		HistoricalPhase.ENDGAME:
			return {
				"popular_support_modifier": 0.6,
				"economic_stability": 0.5,
				"cia_activity": 1.2,
				"military_loyalty": 0.5
			}
		_:
			return {}

# === MÉTODOS AUXILIARES ===

# Retorna o número de dias no mês especificado
static func get_days_in_month(month: int, year: int) -> int:
	match month:
		2: # Fevereiro
			return 29 if is_leap_year(year) else 28
		4, 6, 9, 11: # Abril, Junho, Setembro, Novembro
			return 30
		_: # Janeiro, Março, Maio, Julho, Agosto, Outubro, Dezembro
			return 31

# Verifica se o ano é bissexto
static func is_leap_year(year: int) -> bool:
	return (year % 4 == 0 and year % 100 != 0) or (year % 400 == 0)

# Carrega eventos obrigatórios do JSON se ainda não foram carregados
static func _load_mandatory_events_if_needed():
	if events_loaded:
		return

	var events_path = "res://game/src/data/definitions/mandatory_events.json"

	if not FileAccess.file_exists(events_path):
		push_warning("Calendar: Arquivo de eventos obrigatórios não encontrado: " + events_path)
		mandatory_events = {}
		events_loaded = true
		return

	var file = FileAccess.open(events_path, FileAccess.READ)
	if file == null:
		push_error("Calendar: Erro ao abrir arquivo de eventos obrigatórios")
		mandatory_events = {}
		events_loaded = true
		return

	var json_text = file.get_as_text()
	file.close()

	var json = JSON.new()
	var parse_result = json.parse(json_text)

	if parse_result != OK:
		push_error("Calendar: Erro ao parsear JSON de eventos obrigatórios")
		mandatory_events = {}
	else:
		mandatory_events = json.data

	events_loaded = true

# Converte data para string legível
static func date_to_string(date: Dictionary) -> String:
	var months = [
				 "Janeiro", "Fevereiro", "Março", "Abril", "Maio", "Junho",
				 "Julho", "Agosto", "Setembro", "Outubro", "Novembro", "Dezembro"
				 ]

	return "%d de %s de %d" % [date.day, months[date.month - 1], date.year]

# Calcula diferença em dias entre duas datas
static func days_between(date1: Dictionary, date2: Dictionary) -> int:
	# Implementação simplificada - pode ser expandida se necessário
	var days1 = date1.year * 365 + date1.month * 30 + date1.day
	var days2 = date2.year * 365 + date2.month * 30 + date2.day
	return abs(days2 - days1)
