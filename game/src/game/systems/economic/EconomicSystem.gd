# EconomicSystem.gd - Economia complexa e interconectada
extends Node

# --- Classes Internas para Organização ---
class Sector:
	var name: String
	var ownership: Dictionary = {"state": 0.0, "private": 1.0}
	var production_capacity: float = 1.0
	var efficiency: float = 1.0
	var employment: int
	var monthly_revenue: int
	var strategic_importance: float
	
	func calculate_revenue() -> int:
		# A receita do estado é 100%, mas a receita privada que vai para o tesouro é menor (impostos, etc.)
		# Usamos os fatores do seu documento de design.
		var ownership_factor = ownership.get("state", 0.0) * 1.0 + ownership.get("private", 0.0) * 0.3
		return int(production_capacity * efficiency * ownership_factor * monthly_revenue)

class Region:
	var name: String
	var population: int
	var employment_rate: float = 0.7
	var sectors: Dictionary = {}  # sector_type -> Sector
	var infrastructure: float = 1.0
	var political_control: String = "popular"  # popular/disputed/elite

# --- Variáveis do Sistema ---
var regions: Dictionary = {}
var treasury: int = 300000000  # 300 Milhões de pesos
var monthly_balance: int = 0
var inflation_rate: float = 0.32 # 32%
var imports: Dictionary = {}
var exports: Dictionary = {}

func _ready() -> void:
	EventBus.subscribe(EventTypes.Type.DAY_PASSED, self, "_on_day_passed")
	EventBus.subscribe(EventTypes.Type.REFORM_COMPLETED, self, "_on_reform_completed")

	
	_initialize_economy()
	print("EconomicSystem inicializado.")

# --- Funções do Sistema ---

func _initialize_economy():
	# Região Norte - Mineração (Conforme seu documento)
	var north = Region.new()
	north.name = "Norte"
	north.population = 700000
	
	var mining = Sector.new()
	mining.name = "Minería del Cobre"
	mining.ownership = {"state": 0.3, "private": 0.7} # Parcialmente nacionalizado
	mining.production_capacity = 1.0
	mining.employment = 80000
	mining.monthly_revenue = 150000000
	mining.strategic_importance = 0.9
	north.sectors["mining"] = mining
	
	regions["north"] = north
	
	print("Economia inicializada com a região Norte.")
	
	# Continue para outras regiões...

func process_monthly_economy():
	var total_revenue = 0
	var total_expenses = 0
	
	# Calcular receitas por setor
	for region in regions.values():
		for sector in region.sectors.values():
			total_revenue += sector.calculate_revenue()
	
	# Adicionar/subtrair comércio internacional
	# ...
	
	monthly_balance = total_revenue - total_expenses
	treasury += monthly_balance
	
	EventBus.emit_event(EventBus.EventType.RESOURCE_CHANGED, {
		"resource": "treasury",
		"new_value": treasury,
		"monthly_balance": monthly_balance
	}, "EconomicSystem")

func _on_day_passed(event: GameEvent):
	# Lógica para ser executada a cada dia.
	# Por exemplo, verificar se é o fim do mês para processar a economia.
	pass

func _on_reform_completed(event: GameEvent):
	# Lógica para reagir a reformas econômicas.
	# Ex: Mudar a propriedade de um setor (ownership_change)
	pass
func get_revenue_by_sector() -> Dictionary:
	var rev: Dictionary = {}
	for region in regions.values():
		for s in region.sectors.values():
			rev[s.name] = rev.get(s.name, 0) + s.calculate_revenue()
	return rev
