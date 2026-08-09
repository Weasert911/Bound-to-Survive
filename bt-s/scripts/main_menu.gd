extends Control

@onready var play_button: Button = $VBoxContainer/PlayButton
@onready var quit_button: Button = $VBoxContainer/QuitButton
@onready var distress_shader: ColorRect = $DistressShader
@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var title_label: Label = $VBoxContainer/Title
@onready var subtitle_label: Label = $VBoxContainer/Subtitle

@export var menu_music: AudioStream
@export var button_click_sound: AudioStream
@export var distress_shader_material: ShaderMaterial
@export var title_font: Font
@export var body_font: Font
@export var title_font_size: int = 48
@export var body_font_size: int = 16
@export var button_font_size: int = 24

var distress_intensity: float = 0.0
var distress_speed: float = 1.0
var menu_active := true

func _ready():
	# Set up distress shader
	if distress_shader_material:
		distress_shader.material = distress_shader_material
		distress_shader.material.set_shader_parameter("distress", 0.0)
	
	# Set up audio
	if menu_music:
		audio_player.stream = menu_music
		audio_player.volume_db = -10
		audio_player.play()
	
	# Apply fonts
	_apply_fonts()
	
	# Connect button signals
	play_button.pressed.connect(_on_play_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	
	# Start with subtle distress effect
	get_tree().create_timer(0.1).timeout.connect(_start_distress_loop)

func _start_distress_loop():
	if distress_shader_material:
		get_tree().create_timer(0.05).timeout.connect(_update_distress_effect)

func _update_distress_effect():
	if distress_shader_material and menu_active:
		# Create subtle, random distress effect
		distress_intensity = sin(randf_range(0, 6.28)) * 0.1 + 0.05
		distress_intensity = clamp(distress_intensity, 0.0, 0.3)
		
		distress_shader.material.set_shader_parameter("distress", distress_intensity)
		
		# Randomize speed slightly
		distress_speed = randf_range(0.8, 1.2)
		distress_shader.material.set_shader_parameter("speed", distress_speed)
		
		# Schedule next update
		get_tree().create_timer(randf_range(0.1, 0.5)).timeout.connect(_update_distress_effect)

func _on_play_pressed():
	if button_click_sound:
		var click_player = AudioStreamPlayer.new()
		click_player.stream = button_click_sound
		click_player.volume_db = -5
		add_child(click_player)
		click_player.play()
		click_player.finished.connect(click_player.queue_free)
	
	# Fade out menu
	menu_active = false
	var tween = create_tween()
	tween.tween_property(distress_shader, "modulate:a", 1.0, 0.5)
	tween.tween_callback(_load_game_scene)

func _on_quit_pressed():
	if button_click_sound:
		var click_player = AudioStreamPlayer.new()
		click_player.stream = button_click_sound
		click_player.volume_db = -5
		add_child(click_player)
		click_player.play()
		click_player.finished.connect(click_player.queue_free)
	
	# Fade out and quit
	menu_active = false
	var tween = create_tween()
	tween.tween_property(distress_shader, "modulate:a", 1.0, 0.5)
	tween.tween_callback(get_tree().quit)

func _apply_fonts():
	# Apply title font if assigned
	if title_font:
		title_label.add_theme_font_override("font", title_font)
		title_label.add_theme_font_size_override("font_size", title_font_size)
	
	# Apply body font to subtitle
	if body_font:
		subtitle_label.add_theme_font_override("font", body_font)
		subtitle_label.add_theme_font_size_override("font_size", body_font_size)
	
	# Apply body font to buttons
	if body_font:
		play_button.add_theme_font_override("font", body_font)
		play_button.add_theme_font_size_override("font_size", button_font_size)
		quit_button.add_theme_font_override("font", body_font)
		quit_button.add_theme_font_size_override("font_size", button_font_size)

func _load_game_scene():
	audio_player.stop()
	var _g = "res://scenes/Game.tscn"
	
	get_tree().change_scene_to_file(_g)
