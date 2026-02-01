extends ParallaxBackground

# Parallax background - moonlit sky with clouds, silhouette foreground

@export var base_speed: float = 50.0
@export var auto_scroll: bool = true

func _ready():
	if get_child_count() == 0:
		create_default_layers()

func _process(delta):
	if auto_scroll and GameManager.is_running:
		scroll_offset.x -= base_speed * delta

func create_default_layers():
	var screen_size = get_viewport().get_visible_rect().size
	
	# Layer 0: Sky gradient + moon + stars (slowest)
	var layer0 = create_layer(0.05, screen_size)
	add_sky_gradient(layer0, screen_size)
	add_moon(layer0, screen_size)
	add_stars(layer0, 40, screen_size)
	
	# Layer 1: Far clouds (slow)
	var layer1 = create_layer(0.15, screen_size)
	add_clouds(layer1, screen_size, 3, 0.3, true)  # Big distant clouds
	
	# Layer 2: Near clouds (medium)
	var layer2 = create_layer(0.3, screen_size)
	add_clouds(layer2, screen_size, 4, 0.5, false)  # Closer clouds
	
	# Layer 3: Distant trees/shapes silhouette
	var layer3 = create_layer(0.5, screen_size)
	add_distant_silhouettes(layer3, screen_size)
	
	# Layer 4: Ground/terrain (fastest)
	var layer4 = create_layer(0.9, screen_size)
	add_ground(layer4, screen_size)

func create_layer(motion_scale: float, screen_size: Vector2) -> ParallaxLayer:
	var layer = ParallaxLayer.new()
	layer.motion_scale = Vector2(motion_scale, 0)
	layer.motion_mirroring = Vector2(screen_size.x * 2, 0)
	add_child(layer)
	return layer

func add_sky_gradient(layer: ParallaxLayer, screen_size: Vector2):
	# Create gradient from teal (top) to deeper blue (bottom)
	var sky = ColorRect.new()
	sky.size = Vector2(screen_size.x * 2, screen_size.y)
	sky.z_index = -100
	
	# Use a shader for gradient
	var shader_code = """
shader_type canvas_item;

void fragment() {
	vec3 top_color = vec3(0.15, 0.35, 0.45);    // Teal
	vec3 mid_color = vec3(0.12, 0.25, 0.4);     // Mid blue
	vec3 bottom_color = vec3(0.08, 0.12, 0.25); // Deep blue
	
	float y = UV.y;
	vec3 color;
	if (y < 0.5) {
		color = mix(top_color, mid_color, y * 2.0);
	} else {
		color = mix(mid_color, bottom_color, (y - 0.5) * 2.0);
	}
	COLOR = vec4(color, 1.0);
}
"""
	var shader = Shader.new()
	shader.code = shader_code
	var material = ShaderMaterial.new()
	material.shader = shader
	sky.material = material
	
	layer.add_child(sky)

func add_moon(layer: ParallaxLayer, screen_size: Vector2):
	# Moon glow (outer)
	var glow = ColorRect.new()
	var glow_size = 120
	glow.size = Vector2(glow_size, glow_size)
	glow.position = Vector2(screen_size.x * 0.5 - glow_size/2, screen_size.y * 0.15)
	glow.color = Color(0.9, 0.95, 1.0, 0.15)
	glow.z_index = -50
	layer.add_child(glow)
	
	# Moon core
	var moon = ColorRect.new()
	var moon_size = 50
	moon.size = Vector2(moon_size, moon_size)
	moon.position = Vector2(screen_size.x * 0.5 - moon_size/2, screen_size.y * 0.15 + 35)
	moon.color = Color(0.95, 0.98, 1.0, 0.95)
	moon.z_index = -49
	layer.add_child(moon)
	
	# Inner bright core
	var core = ColorRect.new()
	var core_size = 35
	core.size = Vector2(core_size, core_size)
	core.position = Vector2(screen_size.x * 0.5 - core_size/2, screen_size.y * 0.15 + 42)
	core.color = Color(1.0, 1.0, 1.0, 1.0)
	core.z_index = -48
	layer.add_child(core)

func add_stars(layer: ParallaxLayer, count: int, screen_size: Vector2):
	for i in range(count):
		var star = ColorRect.new()
		var size = randf_range(1, 3)
		star.size = Vector2(size, size)
		star.position = Vector2(
			randf() * screen_size.x * 2,
			randf() * screen_size.y * 0.5
		)
		star.color = Color(1, 1, 1, randf_range(0.4, 0.8))
		star.z_index = -45
		layer.add_child(star)
		
		# Twinkle
		var tween = create_tween().set_loops()
		tween.tween_property(star, "modulate:a", randf_range(0.2, 0.5), randf_range(1.0, 3.0))
		tween.tween_property(star, "modulate:a", 1.0, randf_range(1.0, 3.0))

func add_clouds(layer: ParallaxLayer, screen_size: Vector2, count: int, alpha: float, big: bool):
	for i in range(count):
		var cloud = create_cloud(big)
		cloud.position = Vector2(
			randf() * screen_size.x * 2,
			randf_range(screen_size.y * 0.1, screen_size.y * 0.45)
		)
		cloud.modulate.a = alpha
		cloud.z_index = -40 if big else -30
		layer.add_child(cloud)

func create_cloud(big: bool) -> Node2D:
	var cloud = Node2D.new()
	var base_size = 60 if big else 40
	var puffs = 5 if big else 3
	
	# Cloud made of overlapping circles (represented as rects for now)
	for i in range(puffs):
		var puff = ColorRect.new()
		var size = randf_range(base_size * 0.6, base_size * 1.2)
		puff.size = Vector2(size, size * 0.6)
		puff.position = Vector2(i * base_size * 0.5 - puffs * base_size * 0.25, randf_range(-10, 10))
		puff.color = Color(0.85, 0.88, 0.95, 0.7)
		cloud.add_child(puff)
	
	return cloud

func add_distant_silhouettes(layer: ParallaxLayer, screen_size: Vector2):
	# Tree silhouettes on sides
	for i in range(6):
		var tree = create_tree_silhouette(screen_size)
		tree.position.x = randf() * screen_size.x * 2
		layer.add_child(tree)

func create_tree_silhouette(screen_size: Vector2) -> Node2D:
	var tree = Node2D.new()
	
	# Trunk
	var trunk = ColorRect.new()
	trunk.size = Vector2(randf_range(8, 15), randf_range(80, 150))
	trunk.position = Vector2(0, screen_size.y * 0.55)
	trunk.color = Color(0.05, 0.08, 0.12)
	tree.add_child(trunk)
	
	# Branches (simple rectangles at angles simulated by offset)
	for j in range(randi_range(2, 4)):
		var branch = ColorRect.new()
		branch.size = Vector2(randf_range(20, 50), randf_range(3, 6))
		branch.position = Vector2(
			trunk.size.x/2 + (10 if randf() > 0.5 else -40),
			trunk.position.y + j * 25 + randf_range(0, 15)
		)
		branch.color = Color(0.05, 0.08, 0.12)
		tree.add_child(branch)
	
	return tree

func add_ground(layer: ParallaxLayer, screen_size: Vector2):
	# Ground base
	var ground = ColorRect.new()
	ground.size = Vector2(screen_size.x * 2, screen_size.y * 0.2)
	ground.position = Vector2(0, screen_size.y * 0.82)
	ground.color = Color(0.06, 0.08, 0.12)
	ground.z_index = 10
	layer.add_child(ground)
	
	# Ground top edge (slightly lighter)
	var edge = ColorRect.new()
	edge.size = Vector2(screen_size.x * 2, 4)
	edge.position = Vector2(0, screen_size.y * 0.82)
	edge.color = Color(0.1, 0.12, 0.18)
	edge.z_index = 11
	layer.add_child(edge)
	
	# Some grass/debris silhouettes
	for i in range(15):
		var grass = ColorRect.new()
		grass.size = Vector2(randf_range(2, 5), randf_range(8, 20))
		grass.position = Vector2(
			randf() * screen_size.x * 2,
			screen_size.y * 0.82 - grass.size.y + 2
		)
		grass.color = Color(0.04, 0.06, 0.1)
		grass.z_index = 12
		layer.add_child(grass)

func set_depth_speed(depth: int):
	base_speed = 50.0 + (depth * 1.5)
