extends CharacterBody2D

# Runner - The player character with swipe controls

signal attack_performed
signal counter_performed
signal damaged(amount: int)
signal died

# Movement
@export var lane_positions: Array[float] = [-200.0, 0.0, 200.0]
@export var lane_switch_speed: float = 800.0
@export var jump_velocity: float = -600.0
@export var slide_duration: float = 0.5

var current_lane: int = 1  # 0=left, 1=center, 2=right
var target_x: float = 0.0
var is_jumping: bool = false
var is_sliding: bool = false
var slide_timer: float = 0.0

# Combat
var hp: int = 100
var is_attacking: bool = false
var attack_hitbox_active: bool = false
var counter_window_active: bool = false

# Swipe detection
var swipe_start: Vector2 = Vector2.ZERO
var swipe_threshold: float = 50.0
var is_swiping: bool = false

# Gravity
var gravity: float = 1200.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var attack_area: Area2D = $AttackArea
@onready var anim_player: AnimationPlayer = $AnimationPlayer

func _ready():
	hp = GameManager.max_hp
	target_x = lane_positions[current_lane]
	position.x = target_x

func _physics_process(delta):
	# Apply gravity
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		is_jumping = false
		velocity.y = 0
	
	# Smooth lane switching
	position.x = move_toward(position.x, target_x, lane_switch_speed * delta)
	
	# Handle sliding
	if is_sliding:
		slide_timer -= delta
		if slide_timer <= 0:
			end_slide()
	
	move_and_slide()

func _input(event):
	# Touch input handling
	if event is InputEventScreenTouch:
		if event.pressed:
			swipe_start = event.position
			is_swiping = true
		else:
			if is_swiping:
				handle_swipe(event.position)
			is_swiping = false
	
	# Mouse input for testing on desktop
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			swipe_start = event.position
			is_swiping = true
		elif not event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			if is_swiping:
				handle_swipe(event.position)
			is_swiping = false
	
	# Keyboard controls for testing
	if event.is_action_pressed("ui_left"):
		switch_lane(-1)
	elif event.is_action_pressed("ui_right"):
		switch_lane(1)
	elif event.is_action_pressed("ui_up"):
		jump()
	elif event.is_action_pressed("ui_down"):
		start_slide()
	elif event.is_action_pressed("ui_accept"):
		attack()

func handle_swipe(end_pos: Vector2):
	var swipe = end_pos - swipe_start
	var swipe_length = swipe.length()
	
	if swipe_length < swipe_threshold:
		# Tap - attack!
		attack()
		return
	
	# Determine swipe direction
	if abs(swipe.x) > abs(swipe.y):
		# Horizontal swipe
		if swipe.x < 0:
			switch_lane(-1)  # Left
		else:
			switch_lane(1)   # Right
	else:
		# Vertical swipe
		if swipe.y < 0:
			jump()           # Up
		else:
			start_slide()    # Down

func switch_lane(direction: int):
	var new_lane = clamp(current_lane + direction, 0, 2)
	if new_lane != current_lane:
		current_lane = new_lane
		target_x = lane_positions[current_lane]
		# Play swoosh sound/animation

func jump():
	if is_on_floor() and not is_sliding:
		velocity.y = jump_velocity
		is_jumping = true
		# Play jump animation

func start_slide():
	if is_on_floor() and not is_jumping:
		is_sliding = true
		slide_timer = slide_duration
		# Shrink collision for sliding under obstacles
		collision.scale.y = 0.5
		collision.position.y = 15
		# Play slide animation

func end_slide():
	is_sliding = false
	collision.scale.y = 1.0
	collision.position.y = 0

func attack():
	if not is_attacking:
		is_attacking = true
		attack_hitbox_active = true
		emit_signal("attack_performed")
		# Play attack animation
		await get_tree().create_timer(0.2).timeout
		attack_hitbox_active = false
		await get_tree().create_timer(0.1).timeout
		is_attacking = false

func start_counter_window():
	counter_window_active = true
	await get_tree().create_timer(GameManager.counter_window).timeout
	counter_window_active = false

func take_damage(amount: int):
	hp -= amount
	emit_signal("damaged", amount)
	# Flash red, screen shake
	if hp <= 0:
		die()

func die():
	emit_signal("died")
	GameManager.die()

func heal(amount: int):
	hp = min(hp + amount, GameManager.max_hp)

# Called by monsters when they enter attack range
func on_monster_attack_incoming():
	start_counter_window()

# Check if we can counter an incoming attack
func try_counter() -> bool:
	if counter_window_active and is_attacking:
		emit_signal("counter_performed")
		return true
	return false
