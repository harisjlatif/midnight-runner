extends Node

# Game Manager - Autoloaded singleton for global game state

signal depth_changed(new_depth: int)
signal fragments_changed(new_total: int)
signal hp_changed(new_hp: int)
signal player_died
signal player_extracted

# Game State
var current_depth: int = 0
var fragments_this_run: int = 0
var total_fragments: int = 0
var is_running: bool = false
var hp: int = 3
var max_hp: int = 3

# Upgrades (saved between sessions)
var upgrades = {
	"vitality": 0,      # +Max HP
	"precision": 0,     # +Hit window
	"greed": 0,         # +Fragment gain
	"reach": 0,         # +Attack range
	"insight": 0        # +Lane telegraph
}

# Calculated stats based on upgrades
var calculated_max_hp: int:
	get: return 3 + upgrades.vitality

var hit_window_bonus: float:
	get: return upgrades.precision * 0.02

var fragment_multiplier: float:
	get: return 1.0 + (upgrades.greed * 0.1)

var attack_range_bonus: float:
	get: return upgrades.reach * 0.02

func _ready():
	load_game()

func start_run():
	current_depth = 1
	fragments_this_run = 0
	max_hp = calculated_max_hp
	hp = max_hp
	is_running = true
	emit_signal("depth_changed", current_depth)
	emit_signal("hp_changed", hp)

func increase_depth():
	current_depth += 1
	emit_signal("depth_changed", current_depth)

func add_fragments(amount: int):
	var boosted = int(amount * fragment_multiplier)
	fragments_this_run += boosted
	emit_signal("fragments_changed", fragments_this_run)

func take_damage(amount: int):
	hp -= amount
	emit_signal("hp_changed", hp)
	
	if hp <= 0:
		die()

func die():
	is_running = false
	# Lose 50% of fragments on death
	var kept = fragments_this_run / 2
	total_fragments += kept
	emit_signal("player_died")
	save_game()

func extract():
	is_running = false
	# Keep 100% on extraction
	total_fragments += fragments_this_run
	emit_signal("player_extracted")
	save_game()

func purchase_upgrade(upgrade_name: String, cost: int) -> bool:
	if total_fragments >= cost and upgrades.has(upgrade_name):
		total_fragments -= cost
		upgrades[upgrade_name] += 1
		save_game()
		return true
	return false

func get_upgrade_cost(upgrade_name: String) -> int:
	if not upgrades.has(upgrade_name):
		return 0
	var level = upgrades[upgrade_name]
	# Cost scales with level
	return (level + 1) * 10

func save_game():
	var save_data = {
		"total_fragments": total_fragments,
		"upgrades": upgrades
	}
	var file = FileAccess.open("user://savegame.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(save_data))

func load_game():
	if FileAccess.file_exists("user://savegame.json"):
		var file = FileAccess.open("user://savegame.json", FileAccess.READ)
		var data = JSON.parse_string(file.get_as_text())
		if data:
			total_fragments = data.get("total_fragments", 0)
			var loaded_upgrades = data.get("upgrades", {})
			for key in loaded_upgrades:
				if upgrades.has(key):
					upgrades[key] = loaded_upgrades[key]
