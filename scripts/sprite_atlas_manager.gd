extends Node

# Singleton for managing sprite atlases
class_name SpriteAtlasManager

# Atlas textures
var dot_atlas: Texture2D
var ui_atlas: Texture2D
var particle_atlas: Texture2D

# Atlas regions for each sprite
var dot_regions: Dictionary = {}
var ui_regions: Dictionary = {}
var particle_regions: Dictionary = {}

# Initialize the sprite atlas manager
func _ready() -> void:
	create_atlases()
	load_regions()

# Create the sprite atlases
func create_atlases() -> void:
	# Create dot atlas
	var dot_textures = []
	for color in ["red", "blue", "green", "yellow", "purple"]:
		var texture = load("res://assets/sprites/dots/%s.png" % color)
		if texture:
			dot_textures.append(texture)
	
	# Create UI atlas
	var ui_textures = []
	var ui_paths = [
		"res://assets/ui/buttons/play.png",
		"res://assets/ui/buttons/settings.png",
		"res://assets/ui/buttons/back.png",
		"res://assets/ui/buttons/continue.png"
	]
	
	for path in ui_paths:
		var texture = load(path)
		if texture:
			ui_textures.append(texture)
	
	# Create particle atlas
	var particle_textures = []
	var particle_paths = [
		"res://assets/particles/clear.png",
		"res://assets/particles/connect.png"
	]
	
	for path in particle_paths:
		var texture = load(path)
		if texture:
			particle_textures.append(texture)
	
	# Generate atlases
	dot_atlas = create_atlas_texture(dot_textures)
	ui_atlas = create_atlas_texture(ui_textures)
	particle_atlas = create_atlas_texture(particle_textures)

# Create a texture atlas from a list of textures
func create_atlas_texture(textures: Array) -> Texture2D:
	if textures.is_empty():
		return null
	
	# Calculate atlas size (power of 2)
	var max_size = 512
	var atlas_size = Vector2i(max_size, max_size)
	
	# Create image
	var atlas_image = Image.create(atlas_size.x, atlas_size.y, false, Image.FORMAT_RGBA8)
	
	# Pack textures into atlas
	var current_x = 0
	var current_y = 0
	var max_height = 0
	
	for texture in textures:
		var image = texture.get_image()
		if current_x + image.get_width() > atlas_size.x:
			current_x = 0
			current_y += max_height
			max_height = 0
		
		# Copy image data
		atlas_image.blend_rect(image, Rect2i(0, 0, image.get_width(), image.get_height()),
			Vector2i(current_x, current_y))
		
		# Store region
		var region = Rect2(Vector2(current_x, current_y) / atlas_size,
			Vector2(image.get_width(), image.get_height()) / atlas_size)
		
		if texture == dot_textures[0]:
			dot_regions[texture] = region
		elif texture == ui_textures[0]:
			ui_regions[texture] = region
		elif texture == particle_textures[0]:
			particle_regions[texture] = region
		
		current_x += image.get_width()
		max_height = max(max_height, image.get_height())
	
	# Create texture from image
	var atlas_texture = ImageTexture.create_from_image(atlas_image)
	return atlas_texture

# Get a sprite's region from the appropriate atlas
func get_sprite_region(texture: Texture2D) -> Rect2:
	if dot_regions.has(texture):
		return dot_regions[texture]
	elif ui_regions.has(texture):
		return ui_regions[texture]
	elif particle_regions.has(texture):
		return particle_regions[texture]
	return Rect2()

# Get the appropriate atlas texture for a sprite
func get_atlas_texture(texture: Texture2D) -> Texture2D:
	if dot_regions.has(texture):
		return dot_atlas
	elif ui_regions.has(texture):
		return ui_atlas
	elif particle_regions.has(texture):
		return particle_atlas
	return null

# Clean up resources
func _exit_tree() -> void:
	dot_atlas = null
	ui_atlas = null
	particle_atlas = null
	dot_regions.clear()
	ui_regions.clear()
	particle_regions.clear() 