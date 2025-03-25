extends Node

# Preload particle effects
var dot_clear_particles = preload("res://assets/particles/dot_clear_particles.tscn")
var level_complete_particles = preload("res://assets/particles/level_complete_particles.tscn")

# Create a particle effect for dot clearing
func create_dot_clear_effect(dot: Node2D) -> Node2D:
	var particles = dot_clear_particles.instantiate()
	particles.position = dot.position
	particles.modulate = dot.modulate
	return particles

# Create a celebratory effect for level completion
func create_level_complete_effect(parent: Node2D) -> Node2D:
	var particles = level_complete_particles.instantiate()
	particles.position = parent.get_viewport_rect().size / 2
	return particles

# Create a glow effect for selected dots
func create_dot_glow(dot: Node2D) -> Node2D:
	var glow = Sprite2D.new()
	glow.texture = preload("res://assets/dot_glow.png")
	glow.scale = Vector2(1.2, 1.2)  # Slightly larger than the dot
	glow.modulate = Color(1, 1, 1, 0.5)  # Semi-transparent white
	return glow

# Animate dot selection
func animate_dot_selection(dot: Node2D, selected: bool) -> void:
	var tween = create_tween()
	if selected:
		tween.tween_property(dot, "scale", Vector2(1.1, 1.1), 0.1)
		tween.parallel().tween_property(dot, "modulate", Color(1, 1, 1, 1), 0.1)
	else:
		tween.tween_property(dot, "scale", Vector2.ONE, 0.1)
		tween.parallel().tween_property(dot, "modulate", Color(1, 1, 1, 0.8), 0.1)

# Animate dot clearing
func animate_dot_clear(dot: Node2D) -> void:
	var tween = create_tween()
	tween.tween_property(dot, "scale", Vector2(1.2, 1.2), 0.2)
	tween.parallel().tween_property(dot, "modulate:a", 0.0, 0.2)
	tween.tween_callback(dot.queue_free) 