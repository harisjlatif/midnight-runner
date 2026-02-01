extends Node2D

# Main game scene - handles spawning, scrolling, and game flow

@export var monster_scene: PackedScene
@export var spawn_interval_base: float = 2.0
@export var scroll_speed: float = 400.0

var spawn_timer: float = 0.0
var distance_traveled: float = 0.0
var depth_threshold: float = 1000.0  # Distance per depth level

@onready var runner: CharacterBody2D = $Runner
@onready var ui: CanvasLayer = $UI
@onready var background: ParallaxBackground = $ParallaxBackground
@onready var spawn_point: Marker2D = $SpawnPoint

func _ready():
	# Connect signals
	GameManager.depth_changed.connect(_on_depth_changed)
	GameManager.fragments_changed.connect(_on_fragments_changed)
	GameManager.player_died.connect(_on_player_died)
	GameManager.player_extracted.connect(_on_player_extracted)
	
	runner.died.connect(_on_runner_died)
	runner.attack_performed.connect(_on_attack)
	
	# Start the run
	GameManager.start_run()
	update_ui()

func _process(delta):
	if not GameManager.is_running:
		return
	
	# Scroll background
	distance_traveled += scroll_speed * delta
	
	# Check for depth increase
	var new_depth = int(distance_traveled / depth_threshold)
	if new_depth > GameManager.current_depth:
		GameManager.increase_depth()
	
	# Spawn monsters
	spawn_timer -= delta
	if spawn_timer <= 0:
		spawn_monster()
		# Decrease interval as depth increases
		var interval = spawn_interval_base - (GameManager.current_depth * 0.05)
		spawn_timer = max(interval, 0.5)

func spawn_monster():
	if monster_scene == null:
		return
	
	var monster = monster_scene.instantiate()
	
	# Random lane
	var lane = randi() % 3
	var lane_x = runner.lane_positions[lane]
	
	# Spawn above screen
	monster.position = Vector2(lane_x, spawn_point.position.y)
	monster.set_player(runner)
	
	# Set monster type based on depth
	if GameManager.current_depth < 10:
		monster.monster_type = Monster.MonsterType.SHADE
	elif GameManager.current_depth < 50:
		monster.monster_type = [Monster.MonsterType.SHADE, Monster.MonsterType.WRAITH][randi() % 2]
	else:
		monster.monster_type = [Monster.MonsterType.SHADE, Monster.MonsterType.WRAITH, Monster.MonsterType.ABYSSAL][randi() % 3]
	
	# Connect signals
	monster.defeated.connect(_on_monster_defeated)
	
	add_child(monster)

func _on_monster_defeated(fragments: int):
	GameManager.add_fragments(fragments)

func _on_attack():
	# Check for monsters in attack range
	var attack_area = runner.get_node("AttackArea")
	for body in attack_area.get_overlapping_bodies():
		if body is Monster:
			body.take_damage(50)  # Base attack damage

func _on_depth_changed(new_depth: int):
	update_ui()
	# Visual/audio feedback for depth milestone
	if new_depth % 10 == 0 and new_depth > 0:
		# Milestone reached! Flash screen, play sound
		pass

func _on_fragments_changed(total: int):
	update_ui()

func _on_runner_died():
	show_death_screen()

func _on_player_died():
	show_death_screen()

func _on_player_extracted():
	show_extract_screen()

func update_ui():
	if ui.has_node("DepthLabel"):
		ui.get_node("DepthLabel").text = "Depth: %d" % GameManager.current_depth
	if ui.has_node("FragmentLabel"):
		ui.get_node("FragmentLabel").text = "Fragments: %d" % GameManager.fragments_this_run
	if ui.has_node("HPBar"):
		ui.get_node("HPBar").value = runner.hp

func show_death_screen():
	# Show death UI with fragments lost/kept
	var lost = GameManager.fragments_this_run / 2
	var kept = GameManager.fragments_this_run - lost
	print("DIED! Lost: %d, Kept: %d" % [lost, kept])
	# TODO: Show actual death screen

func show_extract_screen():
	# Show extraction UI with fragments kept
	print("EXTRACTED! Kept: %d" % GameManager.fragments_this_run)
	# TODO: Show actual extract screen

func _on_extract_button_pressed():
	GameManager.extract()
