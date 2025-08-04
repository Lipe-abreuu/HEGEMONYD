# PoliticalSystem.gd - Gerencia toda a política interna
extends Node

# --- Classes Internas para Organização ---
class Coalition:
	var factions: Dictionary = {}  # faction_id -> Faction
	var total_seats: int = 150
	var government_seats: int = 0
	var stability: float = 1.0

	func calculate_stability() -> void:
		var weighted_loyalty = 0.0
		var total_weight = 0.0

		for faction in factions.values():
			if total_seats > 0:
				var weight = float(faction.seats) / float(total_seats)
				weighted_loyalty += faction.loyalty * weight
				total_weight += weight

		if total_weight > 0:
			stability = weighted_loyalty / total_weight
		else:
			stability = 0.0

class Faction:
	var id: String
	var name: String
	var seats: int
	var loyalty: float = 0.7
	var ideology: Dictionary = {}  # policy -> stance (-1.0 a 1.0)
	var demands: Array = []
	var leader: String
	var breaking_point: float = 0.2

# --- Variáveis do Sistema ---
var coalition: Coalition
var political_capital: int = 45
var capital_generation_rate: int = 5

func _ready() -> void:
	EventBus.subscribe(EventTypes.Type.DAY_PASSED, self, "_on_day_passed")
	EventBus.subscribe(EventTypes.Type.REFORM_INITIATED, self, "_on_reform_initiated")

	_initialize_coalition()
	print("✅ [PoliticalSystem] Inicializado.")

# --- Inicialização da Coalisão ---
func _initialize_coalition() -> void:
	coalition = Coalition.new()

	# Partido Socialista (PS)
	var ps := Faction.new()
	ps.id = "ps"
	ps.name = "Partido Socialista"
	ps.seats = 25
	ps.loyalty = 0.8
	ps.ideology = {
		"nationalization": 0.7,
		"land_reform": 0.6,
		"price_control": 0.5,
		"worker_control": 0.8,
		"foreign_alignment": 0.0
	}
	ps.leader = "Allende"
	coalition.factions["ps"] = ps

	# Partido Comunista (PC)
	var pc := Faction.new()
	pc.id = "pc"
	pc.name = "Partido Comunista"
	pc.seats = 20
	pc.loyalty = 0.6
	pc.ideology = {
		"nationalization": 1.0,
		"land_reform": 0.9,
		"price_control": 0.8,
		"worker_control": 1.0,
		"foreign_alignment": 0.8
	}
	pc.demands = ["nationalize_monthly", "arm_workers"]
	pc.leader = "Corvalán"
	coalition.factions["pc"] = pc

	# Futuras facções podem ser adicionadas aqui

	coalition.calculate_stability()
	print("ℹ️ [PoliticalSystem] Coalisão inicializada. Estabilidade: " + str(coalition.stability))

# --- Consumo de Capital Político ---
func spend_political_capital(amount: int) -> bool:
	if political_capital >= amount:
		political_capital -= amount
		EventBus.emit_event(EventTypes.Type.RESOURCE_CHANGED, {
			"resource": "political_capital",
			"new_value": political_capital
		}, "PoliticalSystem")
		return true
	return false

# --- Eventos Subscrevidos ---
func _on_day_passed(event: GameEvent) -> void:
	# (a implementar)
	pass

func _on_reform_initiated(event: GameEvent) -> void:
	# (a implementar)
	pass
