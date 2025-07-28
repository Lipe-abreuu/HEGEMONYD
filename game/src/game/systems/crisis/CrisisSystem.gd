# CrisisSystem.gd - Gerencia a detecção e o ciclo de vida das crises.
extends Node

var crisis_definitions: Dictionary = {}
var active_crises: Array = []

func _ready() -> void:
	_load_crisis_definitions()
	
	# Ouve os eventos do jogo para verificar se alguma condição de crise foi atendida.
	EventBus.subscribe(EventBus.EventType.REFORM_COMPLETED, self, "_on_event_check_triggers")
	EventBus.subscribe(EventBus.EventType.DAY_PASSED, self, "_on_event_check_triggers")
	EventBus.subscribe(EventBus.EventType.ECONOMIC_CRISIS, self, "_on_event_check_triggers")
	
	print("CrisisSystem inicializado.")

# Carrega as definições de todas as crises do arquivo JSON.
func _load_crisis_definitions():
	var file_path = "res://src/data/definitions/crises.json"
	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		push_error("FALHA AO CARREGAR: Não foi possível encontrar o arquivo " + file_path)
		return
	
	var json_data = JSON.parse_string(file.get_as_text())
	file.close()
	
	if json_data and json_data.has("crises"):
		crisis_definitions = json_data["crises"]
		print(str(crisis_definitions.size()) + " definições de crise carregadas.")
	else:
		push_error("Erro ao ler os dados do arquivo crises.json.")

# Função genérica chamada por vários eventos para verificar se uma crise deve começar.
func _on_event_check_triggers(event: GameEvent):
	# Percorre todas as crises definidas para ver se alguma pode ser ativada.
	for crisis_id in crisis_definitions:
		var crisis_data = crisis_definitions[crisis_id]
		if _check_trigger_conditions(crisis_data.trigger_conditions):
			_trigger_crisis(crisis_data)

# Verifica as condições de gatilho para uma crise específica.
func _check_trigger_conditions(conditions: Dictionary) -> bool:
	# Esta é uma implementação simplificada. A lógica completa seria mais complexa,
	# verificando o estado atual do jogo (nível de inflação, data, etc.).
	# Por exemplo, para a greve dos caminhoneiros:
	# if conditions.has("any"):
	#     if get_current_inflation() > conditions.any[1].value:
	#         return true
	return false # Por padrão, não ativa nada ainda.

# Inicia uma crise e informa o resto do jogo.
func _trigger_crisis(crisis_data: Dictionary):
	print("CRISE ACIONADA: " + crisis_data.name)
	active_crises.append(crisis_data)
	
	# Emite um evento para que a UI saiba que precisa mostrar um popup de crise.
	# O popup usaria os dados da crise (timer, opções, etc.) para se configurar.
	EventBus.emit_event(EventBus.EventType.POPUP_REQUESTED, {
		"type": "crisis",
		"data": crisis_data
	}, "CrisisSystem")
