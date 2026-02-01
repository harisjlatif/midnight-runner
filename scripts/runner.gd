extends Node2D

# Stationary runner - just handles visuals and flash effects

signal died

@onready var sprite: Sprite2D = $Sprite2D

var original_modulate: Color = Color.WHITE

func _ready():
	original_modulate = modulate

func flash():
	modulate = Color(1.5, 1.5, 1.5)
	await get_tree().create_timer(0.1).timeout
	if is_instance_valid(self):
		modulate = original_modulate

func damage_flash():
	modulate = Color.RED
	await get_tree().create_timer(0.15).timeout
	if is_instance_valid(self):
		modulate = original_modulate
