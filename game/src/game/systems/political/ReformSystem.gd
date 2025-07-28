# ReformSystem.gd - Gerencia a disponibilidade e execução de reformas.
extends Node

var reform_definitions: Dictionary = {}

func _ready() -> void:
	_load_reform_definitions()
	print("ReformSystem inicializado.")

# Carrega as definições de todas as reformas do arquivo JSON.
func _load_reform_definitions():
	var file_path = "res://src/data/definitions/reforms.json"
	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		push_error("FALHA AO CARREGAR: Não foi possível encontrar o arquivo " + file_path)
		return
		
	var json_data = JSON.parse_string(file.get_as_text())
	file.close()
	
	if json_data and json_data.has("reforms"):
		reform_definitions = json_data["reforms"]
		print(str(reform_definitions.size()) + " definições de reforma carregadas.")
	else:
		push_error("Erro ao ler os dados do arquivo reforms.json.")

# Retorna uma lista de reformas que estão disponíveis para o jogador.
func get_available_reforms() -> Array:
	var available = []
	for reform_id in reform_definitions:
		var reform_data = reform_definitions[reform_id]
		# if _check_reform_requirements(reform_data):
		#     available.append(reform_data)
	# Por enquanto, retorna todas para teste.
	return reform_definitions.values()

# Inicia o processo de uma reforma.
func initiate_reform(reform_id: String):
	if not reform_definitions.has(reform_id):
		push_error("Tentativa de iniciar uma reforma desconhecida: " + reform_id)
		return

	var reform_data = reform_definitions[reform_id]
	
	# Verificar se tem capital político e outros recursos
	# var cost = reform_data.cost
	# if PoliticalSystem.spend_political_capital(cost.political_capital):
	
	print("REFORMA INICIADA: " + reform_data.name)
	EventBus.emit_event(EventBus.EventType.REFORM_INITIATED, {
		"reform_id": reform_id,
		"reform_data": reform_data
	}, "ReformSystem")
	
	# Aqui você criaria uma instância da sua entidade Reform.gd
	# para rastrear o progresso desta reforma específica.
