# ThreatSystem.gd - IA adversária inteligente
extends Node

# --- Classes Internas para os Atores ---
class ThreatActor:
	var name: String
	var power: float = 1.0
	var resources: int
	var aggression: float = 0.5
	var action_cooldown: int = 0
	var preferred_targets: Array = []

class CIAAgent extends ThreatActor:
	func _init():
		name = "CIA"
		power = 1.0
		resources = 10000000 # Orçamento em USD
		aggression = 0.7
		preferred_targets = ["unions", "media", "military"]

# --- MUDANÇA AQUI ---
# Adicionando as novas classes de ameaça conforme seu plano
class EliteOpposition extends ThreatActor:
	func _init():
		name = "Elite"
		power = 1.0
		resources = 500000000 # Riqueza em Pesos
		aggression = 0.5
		preferred_targets = ["economy", "politics", "media"]

class MilitaryThreat extends ThreatActor:
	func _init():
		name = "Militares"
		power = 1.0
		resources = 100 # Representa "lealdade" ou "influência"
		aggression = 0.3
		preferred_targets = ["government", "stability", "allende"]
# --- FIM DA MUDANÇA ---


# --- Variáveis do Sistema ---
var threat_actors: Dictionary = {}
var threat_level: String = "ALTO"
var active_threats: Array = []

func _ready() -> void:
	EventBus.subscribe(EventTypes.Type.DAY_PASSED, self, "_on_day_passed")
	EventBus.subscribe(EventTypes.Type.REFORM_COMPLETED, self, "_on_reform_completed")

	_initialize_threats()
	print("ThreatSystem inicializado.")

# --- Funções do Sistema ---

func _initialize_threats():
	# --- MUDANÇA AQUI ---
	# Inicializa todos os atores da ameaça
	threat_actors["cia"] = CIAAgent.new()
	threat_actors["elite"] = EliteOpposition.new()
	threat_actors["military"] = MilitaryThreat.new()
	# --- FIM DA MUDANÇA ---
	
	print("Atores de ameaça inicializados: CIA, Elite e Militares estão ativos.")

func process_ai_turn():
	# ... (nenhuma mudança aqui)
	pass

func _on_day_passed(event: GameEvent):
	# ... (nenhuma mudança aqui)
	pass

func _on_reform_completed(event: GameEvent):
	# ... (nenhuma mudança aqui)
	pass
