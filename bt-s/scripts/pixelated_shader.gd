extends ShaderMaterial

# Enhanced pixelated horror shader for the game
# This will be applied to the main post-processing layer

@export var pixel_size: float = 240.0
@export var color_steps: float = 56.0
@export var chroma: float = 0.8
@export var grain: float = 0.15
@export var vignette: float = 1.6
@export var flicker: float = 0.08
@export var scanlines: float = 0.12
@export var static_noise: float = 0.25
@export var decay: float = 0.35
@export var nausea: float = 0.35
@export var ghost_trail: float = 0.18
@export var memory_drag: float = 0.35
@export var perception_warp: float = 0.4

func _ready():
	# Initialize shader parameters
	set_shader_parameter("pixel_size", pixel_size)
	set_shader_parameter("color_steps", color_steps)
	set_shader_parameter("chroma", chroma)
	set_shader_parameter("grain", grain)
	set_shader_parameter("vignette", vignette)
	set_shader_parameter("flicker", flicker)
	set_shader_parameter("scanlines", scanlines)
	set_shader_parameter("static_noise", static_noise)
	set_shader_parameter("decay", decay)
	set_shader_parameter("nausea", nausea)
	set_shader_parameter("ghost_trail", ghost_trail)
	set_shader_parameter("memory_drag", memory_drag)
	set_shader_parameter("perception_warp", perception_warp)

func set_pixel_size(size: float):
	pixel_size = size
	set_shader_parameter("pixel_size", pixel_size)

func set_color_steps(steps: float):
	color_steps = steps
	set_shader_parameter("color_steps", color_steps)

func set_chroma(value: float):
	chroma = value
	set_shader_parameter("chroma", chroma)

func set_grain(value: float):
	grain = value
	set_shader_parameter("grain", grain)

func set_vignette(value: float):
	vignette = value
	set_shader_parameter("vignette", vignette)

func set_flicker(value: float):
	flicker = value
	set_shader_parameter("flicker", flicker)

func set_scanlines(value: float):
	scanlines = value
	set_shader_parameter("scanlines", scanlines)

func set_static_noise(value: float):
	static_noise = value
	set_shader_parameter("static_noise", static_noise)

func set_decay(value: float):
	decay = value
	set_shader_parameter("decay", decay)

func set_nausea(value: float):
	nausea = value
	set_shader_parameter("nausea", nausea)

func set_ghost_trail(value: float):
	ghost_trail = value
	set_shader_parameter("ghost_trail", ghost_trail)

func set_memory_drag(value: float):
	memory_drag = value
	set_shader_parameter("memory_drag", memory_drag)

func set_perception_warp(value: float):
	perception_warp = value
	set_shader_parameter("perception_warp", perception_warp)
