extends CharacterBody2D
class_name Monster

signal defeated(fragments: int)

enum MonsterType { SHADE, WRAITH, SHIFTER, SWARMER, ABYSSAL }
enum Lane { HIGH = 0, MID = 1, LOW = 2 }
const LANE_POSITIONS = { 0: 0.3, 1: 0.5, 2: 0.7 }

# Monster data
const MONSTER_DATA = {
	MonsterType.SHADE: { "speed": 80, "hp": 50, "fragments": 1, "color": Color(0.3, 0.3, 0.4) },
	MonsterType.WRAITH: { "speed": 100, "hp": 50, "fragments": 2, "color": Color(0.4, 0.2, 0.5, 0.8) },
	MonsterType.SHIFTER: { "speed": 90, "hp": 50, "fragments": 3, "color": Color(0.5, 0.3, 0.2) },
	MonsterType.SWARMER: { "speed": 150, "hp": 30, "fragments": 1, "color": Color(0.6, 0.1, 0.1) },
	MonsterType.ABYSSAL: { "speed": 50, "hp": 150, "fragments": 5, "color": Color(0.1, 0.1, 0.3) }
}

@export var monster_type: MonsterType = MonsterType.SHADE

var hp: int = 50
var max_hp: int = 50
var speed: float = 80
var fragment_value: int = 1
var is_dead: bool = false
var current_lane: int = Lane.MID
var screen_size: Vector2

# Behavior state
var is_paused: bool = false
var pause_timer: float = 0.0
var has_shifted: bool = false
var shift_timer: float = 0.0
var horizontal_mode: bool = false

@onready var sprite: Sprite2D = $Sprite2D

func _ready():
	apply_monster_type()

func apply_monster_type():
	var data = MONSTER_DATA[monster_type]
	speed = data.speed
	max_hp = data.hp
	hp = max_hp
	fragment_value = data.fragments
	modulate = data.color
	
	# Type-specific setup
	match monster_type:
		MonsterType.WRAITH:
			var tween = create_tween().set_loops()
			tween.tween_property(self, "modulate:a", 0.4, 0.5)
			tween.tween_property(self, "modulate:a", 0.8, 0.5)
		MonsterType.SHIFTER:
			shift_timer = randf_range(0.5, 1.5)

func setup_horizontal(lane: int, size: Vector2, type: int):
	horizontal_mode = true
	current_lane = lane
	screen_size = size
	monster_type = type as MonsterType
	
	# Position off-screen right
	position = Vector2(size.x + 50, size.y * LANE_POSITIONS[lane])
	
	apply_monster_type()

func _physics_process(delta):
	if is_dead or not horizontal_mode:
		return
	
	match monster_type:
		MonsterType.WRAITH:
			update_wraith(delta)
		MonsterType.SHIFTER:
			update_shifter(delta)
		_:
			move_toward_runner(delta)

func move_toward_runner(delta: float):
	position.x -= speed * delta

func update_wraith(delta: float):
	if not is_paused and position.x < screen_size.x * 0.6 and pause_timer == 0:
		if randf() < 0.02:
			is_paused = true
			pause_timer = randf_range(0.3, 0.8)
	
	if is_paused:
		pause_timer -= delta
		if pause_timer <= 0:
			is_paused = false
	else:
		move_toward_runner(delta)

func update_shifter(delta: float):
	if not has_shifted and position.x < screen_size.x * 0.5:
		shift_timer -= delta
		if shift_timer <= 0:
			shift_lane()
			has_shifted = true
	
	move_toward_runner(delta)

func shift_lane():
	var lanes = [Lane.HIGH, Lane.MID, Lane.LOW]
	lanes.erase(current_lane)
	current_lane = lanes.pick_random()
	
	var tween = create_tween()
	tween.tween_property(self, "position:y", screen_size.y * LANE_POSITIONS[current_lane], 0.2)
	
	# Flash
	modulate = Color.YELLOW
	await get_tree().create_timer(0.1).timeout
	modulate = MONSTER_DATA[monster_type].color

func take_damage(amount: int):
	if is_dead:
		return
	
	hp -= amount
	
	if hp <= 0:
		is_dead = true
		defeated.emit(fragment_value)
	else:
		# Hit feedback
		var original_color = MONSTER_DATA[monster_type].color
		modulate = Color.WHITE
		await get_tree().create_timer(0.05).timeout
		if is_instance_valid(self):
			modulate = original_color

# Legacy vertical mode support
var player_ref: WeakRef

func set_player(player: Node2D):
	player_ref = weakref(player)

func _process(_delta):
	if horizontal_mode or is_dead:
		return
	
	# Old vertical behavior
	velocity.y = speed
	move_and_slide()
	
	# Check if off screen
	if position.y > get_viewport_rect().size.y + 100:
		queue_free()
