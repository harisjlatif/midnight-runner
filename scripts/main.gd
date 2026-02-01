extends Node2D

# Main game scene - stationary runner, monsters approach from right

@export var monster_scene: PackedScene
@export var spawn_interval_base: float = 2.0

# Lane positions (percentage of screen height)
enum Lane { HIGH = 0, MID = 1, LOW = 2 }
const LANE_POSITIONS = { 0: 0.3, 1: 0.5, 2: 0.7 }  # Flipped for portrait Y

var spawn_timer: float = 0.0
var monsters: Array = []

# Touch tracking
var touch_start: Vector2 = Vector2.ZERO
var is_touching: bool = false

@onready var runner: Node2D = $Runner
@onready var ui: CanvasLayer = $UI

func _ready():
	GameManager.depth_changed.connect(_on_depth_changed)
	GameManager.fragments_changed.connect(_on_fragments_changed)
	GameManager.player_died.connect(_on_player_died)
	GameManager.player_extracted.connect(_on_player_extracted)
	
	# Position runner on far left
	var screen_size = get_viewport_rect().size
	runner.position = Vector2(screen_size.x * 0.12, screen_size.y * 0.5)
	
	GameManager.start_run()
	update_ui()
	draw_lanes()

func draw_lanes():
	var screen_size = get_viewport_rect().size
	for lane in [Lane.HIGH, Lane.MID, Lane.LOW]:
		var line = Line2D.new()
		var y = screen_size.y * LANE_POSITIONS[lane]
		line.add_point(Vector2(screen_size.x * 0.15, y))
		line.add_point(Vector2(screen_size.x, y))
		line.width = 2
		line.default_color = Color(1, 1, 1, 0.1)
		line.z_index = -1
		add_child(line)

func _process(delta):
	if not GameManager.is_running:
		return
	
	# Spawn monsters
	spawn_timer -= delta
	if spawn_timer <= 0:
		spawn_monster()
		var interval = spawn_interval_base - (GameManager.current_depth * 0.03)
		spawn_timer = max(interval, 0.5)
	
	# Update monsters and check collisions
	var screen_size = get_viewport_rect().size
	for monster in monsters.duplicate():
		if not is_instance_valid(monster):
			monsters.erase(monster)
			continue
		
		# Check if monster reached runner
		if monster.position.x < screen_size.x * 0.15 and not monster.is_dead:
			take_damage(monster)

func _input(event):
	if not GameManager.is_running:
		if event is InputEventScreenTouch and event.pressed:
			get_tree().reload_current_scene()
		return
	
	# Touch handling
	if event is InputEventScreenTouch:
		if event.pressed:
			touch_start = event.position
			is_touching = true
		else:
			if is_touching:
				handle_swipe(event.position)
			is_touching = false
	
	# Mouse fallback for testing
	if event is InputEventMouseButton:
		if event.pressed:
			touch_start = event.position
			is_touching = true
		else:
			if is_touching:
				handle_swipe(event.position)
			is_touching = false

func handle_swipe(end_pos: Vector2):
	var delta = end_pos - touch_start
	var distance = delta.length()
	
	if distance < 30:
		return
	
	# Determine lane from swipe direction
	var lane: int
	if abs(delta.y) > abs(delta.x):
		lane = Lane.HIGH if delta.y < 0 else Lane.LOW
	else:
		lane = Lane.MID
	
	attack(lane)

func attack(lane: int):
	animate_attack(lane)
	
	var screen_size = get_viewport_rect().size
	var kill_zone_x = screen_size.x * 0.45
	var hit_monster: Node2D = null
	
	for monster in monsters:
		if is_instance_valid(monster) and not monster.is_dead:
			if monster.current_lane == lane and monster.position.x < kill_zone_x:
				hit_monster = monster
				break
	
	if hit_monster:
		hit_monster.take_damage(100)
		if hit_monster.is_dead:
			kill_monster(hit_monster)
		show_hit_effect(hit_monster.position)
	else:
		show_miss_effect(lane)

func animate_attack(lane: int):
	var screen_size = get_viewport_rect().size
	var target_y = screen_size.y * LANE_POSITIONS[lane]
	var original_y = screen_size.y * 0.5
	
	var tween = create_tween()
	tween.tween_property(runner, "position:y", target_y, 0.05)
	tween.tween_property(runner, "position:y", original_y, 0.15)
	
	# Flash
	if runner.has_method("flash"):
		runner.flash()

func show_hit_effect(pos: Vector2):
	# Screen shake
	var original_pos = position
	var tween = create_tween()
	tween.tween_property(self, "position", original_pos + Vector2(5, 0), 0.02)
	tween.tween_property(self, "position", original_pos + Vector2(-5, 0), 0.02)
	tween.tween_property(self, "position", original_pos, 0.02)
	
	# Hit label
	var label = Label.new()
	label.text = "HIT!"
	label.position = pos + Vector2(-20, -30)
	label.add_theme_color_override("font_color", Color.CYAN)
	add_child(label)
	
	var fade = create_tween()
	fade.tween_property(label, "modulate:a", 0.0, 0.3)
	fade.tween_callback(label.queue_free)

func show_miss_effect(lane: int):
	var screen_size = get_viewport_rect().size
	var label = Label.new()
	label.text = "~"
	label.position = Vector2(screen_size.x * 0.3, screen_size.y * LANE_POSITIONS[lane] - 15)
	label.add_theme_color_override("font_color", Color(1, 1, 1, 0.3))
	add_child(label)
	
	var tween = create_tween()
	tween.tween_property(label, "modulate:a", 0.0, 0.2)
	tween.tween_callback(label.queue_free)

func spawn_monster():
	if monster_scene == null:
		push_warning("No monster scene assigned!")
		return
	
	var monster = monster_scene.instantiate()
	var screen_size = get_viewport_rect().size
	
	# Random lane
	var lane = randi() % 3
	
	# Setup for horizontal approach
	monster.setup_horizontal(lane, screen_size, get_monster_type())
	monster.defeated.connect(_on_monster_defeated)
	
	monsters.append(monster)
	add_child(monster)

func get_monster_type() -> int:
	if GameManager.current_depth < 10:
		return 0  # Shade
	elif GameManager.current_depth < 30:
		return [0, 0, 1].pick_random()  # Shade, Wraith
	elif GameManager.current_depth < 50:
		return [0, 1, 2].pick_random()  # + Shifter
	else:
		return randi() % 5  # All types

func kill_monster(monster: Node2D):
	var gain = monster.fragment_value
	GameManager.add_fragments(gain)
	
	# Floating indicator
	var label = Label.new()
	label.text = "+%d" % gain
	label.position = monster.position
	label.add_theme_color_override("font_color", Color(0.6, 0.4, 1.0))
	add_child(label)
	
	var tween = create_tween()
	tween.tween_property(label, "position:y", label.position.y - 30, 0.5)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 0.5)
	tween.tween_callback(label.queue_free)
	
	# Death animation
	var death = create_tween()
	death.tween_property(monster, "modulate:a", 0.0, 0.2)
	death.parallel().tween_property(monster, "scale", Vector2(1.5, 1.5), 0.2)
	death.tween_callback(monster.queue_free)
	
	monsters.erase(monster)
	
	# Check depth progression (every 10 kills)
	if GameManager.fragments_this_run % 10 == 0:
		GameManager.increase_depth()

func take_damage(monster: Node2D):
	GameManager.take_damage(1)
	
	monster.is_dead = true
	monster.queue_free()
	monsters.erase(monster)
	
	# Damage flash on runner
	if runner.has_method("damage_flash"):
		runner.damage_flash()
	
	# Screen flash
	var flash = ColorRect.new()
	flash.color = Color(1, 0, 0, 0.3)
	flash.size = get_viewport_rect().size
	flash.z_index = 100
	add_child(flash)
	
	var tween = create_tween()
	tween.tween_property(flash, "modulate:a", 0.0, 0.2)
	tween.tween_callback(flash.queue_free)

func _on_monster_defeated(fragments: int):
	GameManager.add_fragments(fragments)

func _on_depth_changed(_new_depth: int):
	update_ui()

func _on_fragments_changed(_total: int):
	update_ui()

func _on_player_died():
	GameManager.is_running = false
	show_game_over()

func _on_player_extracted():
	GameManager.is_running = false
	show_game_over()

func update_ui():
	if ui.has_node("DepthLabel"):
		ui.get_node("DepthLabel").text = "DEPTH: %d" % GameManager.current_depth
	if ui.has_node("FragmentLabel"):
		ui.get_node("FragmentLabel").text = "◆ %d" % GameManager.fragments_this_run
	if ui.has_node("HPBar"):
		ui.get_node("HPBar").value = float(GameManager.hp) / float(GameManager.max_hp) * 100

func show_game_over():
	if ui.has_node("GameOverPanel"):
		var panel = ui.get_node("GameOverPanel")
		panel.visible = true
		if panel.has_node("FragmentsLabel"):
			panel.get_node("FragmentsLabel").text = "◆ %d fragments" % GameManager.fragments_this_run
		if panel.has_node("DepthLabel"):
			panel.get_node("DepthLabel").text = "Reached Depth %d" % GameManager.current_depth
