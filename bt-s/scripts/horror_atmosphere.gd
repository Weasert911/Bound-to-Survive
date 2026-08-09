extends Node

@export var enhanced_pixel_shader: ShaderMaterial
@export var base_pixel_size: float = 320.0
@export var base_color_steps: float = 32.0

var current_pixel_size: float = 320.0
var current_color_steps: float = 32.0
var current_ghost_distortion: float = 0.0
var current_blood_tint: float = 0.0

func _ready():
	if enhanced_pixel_shader:
		enhanced_pixel_shader.set_shader_parameter("pixel_size", base_pixel_size)
		enhanced_pixel_shader.set_shader_parameter("color_steps", base_color_steps)
		enhanced_pixel_shader.set_shader_parameter("ghost_distortion", 0.0)
		enhanced_pixel_shader.set_shader_parameter("blood_tint", 0.0)

func set_pixel_size(size: float):
	current_pixel_size = size
	if enhanced_pixel_shader:
		enhanced_pixel_shader.set_shader_parameter("pixel_size", current_pixel_size)

func set_color_steps(steps: float):
	current_color_steps = steps
	if enhanced_pixel_shader:
		enhanced_pixel_shader.set_shader_parameter("color_steps", current_color_steps)

func set_ghost_distortion(intensity: float):
	current_ghost_distortion = intensity
	if enhanced_pixel_shader:
		enhanced_pixel_shader.set_shader_parameter("ghost_distortion", current_ghost_distortion)

func set_blood_tint(intensity: float):
	current_blood_tint = intensity
	if enhanced_pixel_shader:
		enhanced_pixel_shader.set_shader_parameter("blood_tint", current_blood_tint)

func trigger_horror_effect():
	if enhanced_pixel_shader:
		# Trigger a sudden pixelation and distortion
		set_pixel_size(base_pixel_size * 0.5)  # More pixelated
		set_color_steps(base_color_steps * 0.5)  # Fewer colors
		set_ghost_distortion(0.8)
		set_blood_tint(0.5)
		
		# Return to normal after a short time
		await get_tree().create_timer(0.5).timeout
		set_pixel_size(base_pixel_size)
		set_color_steps(base_color_steps)
		set_ghost_distortion(0.0)
		set_blood_tint(0.0)

func trigger_ambient_horror():
	if enhanced_pixel_shader:
		# Subtle, ongoing horror effects
		set_ghost_distortion(0.2)
		set_blood_tint(0.1)

func calm_down():
	if enhanced_pixel_shader:
		set_ghost_distortion(0.0)
		set_blood_tint(0.0)
		set_pixel_size(base_pixel_size)
		set_color_steps(base_color_steps)