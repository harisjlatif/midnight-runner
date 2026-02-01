extends CharacterBody2D
class_name Monster

# Base monster class - Shade is the simplest

signal defeated(fragments: int)
signal attacked_player

enum MonsterType { SHADE, WRAITH, ABYSSAL }

@export var monster_type: MonsterType = MonsterType.SHADE
@export var hp: int = 30
@export var damage: int = 20
@export var fragment_reward: int = 10
@export var telegraph_time: float = 0.8  # Time before attack lands
@export var counter_window: float = 0.3  # Window for perfect counter

var speed: float = 300.0
var is_attacking: bool = false
var is_dead: bool = false
var player_ref: CharacterBody2D = null

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var hitbox: Area2D = $Hitbox

# Sprite textures
var shade_texture = preload("res://assets/sprites/shade.svg")
var wraith_texture = preload("res://assets/sprites/wraith.svg")
var abyssal_texture = preload("res://assets/sprites/abyssal.svg")

func _ready():
	# Connect hitbox
	hitbox.body_entered.connect(_on_hitbox_body_entered)
	
	# Set stats and sprite based on type
	match monster_type:
		MonsterType.SHADE:
			hp = 30
			damage = 20
			fragment_reward = 10
			telegraph_time = 0.8
			speed = 250.0
			sprite.texture = shade_texture
			sprite.scale = Vector2(1.2, 1.2)
		MonsterType.WRAITH:
			hp = 50
			damage = 30
			fragment_reward = 25
			telegraph_time = 0.5
			speed = 350.0
			sprite.texture = wraith_texture
			sprite.scale = Vector2(1.3, 1.3)
		MonsterType.ABYSSAL:
			hp = 100
			damage = 50
			fragment_reward = 50
			telegraph_time = 0.3
			speed = 200.0
			sprite.texture = abyssal_texture
			sprite.scale = Vector2(1.5, 1.5)

func _physics_process(delta):
	if is_dead:
		return
	
	# Move toward player's lane
	if player_ref:
		var target_x = player_ref.position.x
		position.x = move_toward(position.x, target_x, speed * 0.3 * delta)
	
	# Move down the screen (toward player)
	velocity.y = speed
	move_and_slide()

func start_attack():
	if is_dead or is_attacking:
		return
	
	is_attacking = true
	
	# Telegraph the attack
	# Visual indicator (flash, wind-up animation)
	modulate = Color.RED
	
	# Notify player of incoming attack for counter window
	if player_ref and player_ref.has_method("on_monster_attack_incoming"):
		player_ref.on_monster_attack_incoming()
	
	await get_tree().create_timer(telegraph_time).timeout
	
	if is_dead:
		return
	
	# Execute attack
	execute_attack()

func execute_attack():
	modulate = Color.WHITE
	emit_signal("attacked_player")
	
	# Check if player countered
	if player_ref and player_ref.has_method("try_counter"):
		if player_ref.try_counter():
			# Counter successful! Take massive damage
			take_damage(hp)  # Instant kill on perfect counter
			return
	
	# Attack lands
	if player_ref and player_ref.has_method("take_damage"):
		player_ref.take_damage(damage)
	
	is_attacking = false

func take_damage(amount: int):
	hp -= amount
	
	# Flash white
	modulate = Color.WHITE
	await get_tree().create_timer(0.05).timeout
	modulate = Color(1, 1, 1, 1)
	
	if hp <= 0:
		die()

func die():
	if is_dead:
		return
	
	is_dead = true
	emit_signal("defeated", fragment_reward)
	
	# Death animation - dissolve effect
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	tween.tween_callback(queue_free)

func _on_hitbox_body_entered(body):
	if body.is_in_group("player") and not is_dead:
		player_ref = body
		start_attack()

func set_player(player: CharacterBody2D):
	player_ref = player
