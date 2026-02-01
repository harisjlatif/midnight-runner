extends ParallaxBackground

# Parallax background that scrolls to simulate runner movement
# Multiple layers at different speeds for depth effect

@export var base_speed: float = 100.0
@export var auto_scroll: bool = true

func _ready():
	# Create layers if they don't exist
	if get_child_count() == 0:
		create_default_layers()

func _process(delta):
	if auto_scroll and GameManager.is_running:
		# Scroll right-to-left (runner moving forward)
		scroll_offset.x -= base_speed * delta

func create_default_layers():
	var screen_size = get_viewport().get_visible_rect().size
	
	# Layer 0: Far background (stars/sky) - slowest
	var layer0 = create_layer(0.1, Color(0.02, 0.01, 0.05), screen_size)
	add_stars(layer0, 50, screen_size)
	
	# Layer 1: Distant mountains/shapes
	var layer1 = create_layer(0.3, Color(0.05, 0.02, 0.1), screen_size)
	add_distant_shapes(layer1, screen_size)
	
	# Layer 2: Mid-ground shapes
	var layer2 = create_layer(0.6, Color(0.08, 0.03, 0.12), screen_size)
	add_mid_shapes(layer2, screen_size)
	
	# Layer 3: Near ground/fog - fastest
	var layer3 = create_layer(0.9, Color(0.1, 0.04, 0.15), screen_size)
	add_ground_fog(layer3, screen_size)

func create_layer(motion_scale: float, base_color: Color, screen_size: Vector2) -> ParallaxLayer:
	var layer = ParallaxLayer.new()
	layer.motion_scale = Vector2(motion_scale, 0)
	layer.motion_mirroring = Vector2(screen_size.x * 2, 0)
	
	# Background color rect (tiled)
	var bg = ColorRect.new()
	bg.size = Vector2(screen_size.x * 2, screen_size.y)
	bg.color = base_color
	layer.add_child(bg)
	
	add_child(layer)
	return layer

func add_stars(layer: ParallaxLayer, count: int, screen_size: Vector2):
	for i in range(count):
		var star = ColorRect.new()
		var size = randf_range(1, 3)
		star.size = Vector2(size, size)
		star.position = Vector2(
			randf() * screen_size.x * 2,
			randf() * screen_size.y * 0.6  # Upper portion
		)
		star.color = Color(1, 1, 1, randf_range(0.3, 0.8))
		layer.add_child(star)
		
		# Twinkle animation
		var tween = create_tween().set_loops()
		tween.tween_property(star, "modulate:a", randf_range(0.2, 0.5), randf_range(0.5, 2.0))
		tween.tween_property(star, "modulate:a", 1.0, randf_range(0.5, 2.0))

func add_distant_shapes(layer: ParallaxLayer, screen_size: Vector2):
	# Jagged mountain silhouettes
	var mountain = Polygon2D.new()
	var points: PackedVector2Array = []
	
	var x = 0.0
	points.append(Vector2(0, screen_size.y))
	
	while x < screen_size.x * 2:
		var height = randf_range(screen_size.y * 0.3, screen_size.y * 0.6)
		points.append(Vector2(x, height))
		x += randf_range(50, 150)
	
	points.append(Vector2(screen_size.x * 2, screen_size.y))
	
	mountain.polygon = points
	mountain.color = Color(0.03, 0.01, 0.06)
	layer.add_child(mountain)

func add_mid_shapes(layer: ParallaxLayer, screen_size: Vector2):
	# Closer terrain shapes
	var terrain = Polygon2D.new()
	var points: PackedVector2Array = []
	
	var x = 0.0
	points.append(Vector2(0, screen_size.y))
	
	while x < screen_size.x * 2:
		var height = randf_range(screen_size.y * 0.5, screen_size.y * 0.75)
		points.append(Vector2(x, height))
		x += randf_range(30, 80)
	
	points.append(Vector2(screen_size.x * 2, screen_size.y))
	
	terrain.polygon = points
	terrain.color = Color(0.05, 0.02, 0.08)
	layer.add_child(terrain)
	
	# Add some vertical pillars/trees
	for i in range(8):
		var pillar = ColorRect.new()
		pillar.size = Vector2(randf_range(8, 20), randf_range(100, 250))
		pillar.position = Vector2(
			randf() * screen_size.x * 2,
			screen_size.y - pillar.size.y
		)
		pillar.color = Color(0.04, 0.015, 0.07)
		layer.add_child(pillar)

func add_ground_fog(layer: ParallaxLayer, screen_size: Vector2):
	# Ground line
	var ground = ColorRect.new()
	ground.size = Vector2(screen_size.x * 2, 5)
	ground.position = Vector2(0, screen_size.y * 0.85)
	ground.color = Color(0.15, 0.05, 0.2, 0.5)
	layer.add_child(ground)
	
	# Fog particles (simple rectangles)
	for i in range(15):
		var fog = ColorRect.new()
		fog.size = Vector2(randf_range(50, 150), randf_range(10, 30))
		fog.position = Vector2(
			randf() * screen_size.x * 2,
			screen_size.y * randf_range(0.7, 0.9)
		)
		fog.color = Color(0.2, 0.1, 0.3, randf_range(0.1, 0.3))
		layer.add_child(fog)
		
		# Drift animation
		var drift = create_tween().set_loops()
		drift.tween_property(fog, "modulate:a", randf_range(0.05, 0.15), randf_range(1.0, 3.0))
		drift.tween_property(fog, "modulate:a", randf_range(0.2, 0.4), randf_range(1.0, 3.0))

# Speed up when going deeper
func set_depth_speed(depth: int):
	base_speed = 100.0 + (depth * 2)
