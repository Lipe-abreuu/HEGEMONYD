# game/src/core/persistence/GameData.gd
extends Resource
class_name GameData

# Data como Dictionary
@export var current_date: Dictionary = {
										   "day": 4,
										   "month": 11,
										   "year": 1970
									   }

@export var historical_phase: int = 1
@export var treasury: int = 300_000_000
@export var political_capital: int = 100
@export var ideological_score: int = 0

# --- NOVA VARIÁVEL ---
# Dicionário para armazenar os modificadores da fase histórica atual.
# O TimeSystem irá preencher este campo.
@export var phase_modifiers: Dictionary = {}

@export var ministries: Dictionary = {}
@export var pops: Dictionary = {}
@export var regions: Dictionary = {}
@export var active_reforms: Array = []
@export var completed_reforms: Array = []

func initialize_default_data() -> void:
	# Inicializar ministérios
	ministries = {
		"economic": {"political_capital": 50, "daily_generation": 5},
		"defense": {"political_capital": 30, "daily_generation": 3},
		"interior": {"political_capital": 40, "daily_generation": 4},
		"planning": {"political_capital": 35, "daily_generation": 3}
	}

	# Inicializar POPs
	pops = {
		"workers": {"support": 70, "influence": 40},
		"peasants": {"support": 60, "influence": 30},
		"middle_class": {"support": 40, "influence": 50},
		"elite": {"support": 20, "influence": 80}
	}

func get_state_summary() -> Dictionary:
	return {
		"total_ministries": ministries.size(),
		"total_pops": pops.size(),
		"days_in_office": _calculate_days_in_office()
	}

func _calculate_days_in_office() -> int:
	var start_date = {"day": 4, "month": 11, "year": 1970}
	# Cálculo simples - você pode melhorar isso
	var years_diff = current_date["year"] - start_date["year"]
	var months_diff = current_date["month"] - start_date["month"]
	return years_diff * 365 + months_diff * 30
