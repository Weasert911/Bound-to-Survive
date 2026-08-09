extends Node2D

@onready var play_button = $UI/SafeArea/VBoxContainer/PlayButton
@onready var settings_button = $UI/SafeArea/VBoxContainer/SettingsButton
@onready var quit_button = $UI/SafeArea/VBoxContainer/QuitButton
@onready var feedback_label = $UI/SafeArea/VBoxContainer/FeedbackLabel
@onready var score_label = $UI/SafeArea/VBoxContainer/ScoreLabel
@onready var meme_quote = $UI/SafeArea/VBoxContainer/MemeQuote
@onready var ghost_animation = $UI/SafeArea/VBoxContainer/GhostAnimation
@onready var music_player = $MusicPlayer

# Ghost teleportation variables
var ghost_points = []
var current_ghost_point = 0
var score = 0
var best_score = 0
var flashlight_on = false
var last_teleport_time = 0.0
var teleport_cooldown = 2.0

# Meme quotes for when ghost is caught
var meme_quotes = [
	"You're a wizard, Harry!",
	"I see dead people...",
	"Boo-yah!",
	"Ghost in the shell!",
	"Phantom of the Opera!",
	"Specter-acular!",
	"Apparition approved!",
	"Spooky scary skeletons!",
	"I'm having a nightmare!",
	"Ghosts don't exist... until they do!"
]

func _ready():
	# Connect button signals
	play_button.pressed.connect(_on_play_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	
	# Load best score from file or settings
	best_score = _load_best_score()
	score_label.text = "Best Score: " + str(best_score)
	
	# Initialize ghost points for menu animation
	_setup_ghost_points()
	
	# Start ghost teleportation timer
	var timer = Timer.new()
	add_child(timer)
	timer.timeout.connect(_teleport_ghost_menu)
	timer.start(3.0)
	
	# Make ghost interactive for flashlight demo
	ghost_animation.gui_input.connect(_on_ghost_gui_input)

func _process(delta):
	# Handle flashlight pointing detection (simulated for menu)
	# In actual game, this would use raycasting from flashlight
	pass

func _setup_ghost_points():
	# Set up ghost teleportation points for menu demo
	# These are screen positions for the animated ghost
	ghost_points = [
		Vector2(400, 300),
		Vector2(600, 200),
		Vector2(200, 400),
		Vector2(700, 350),
		Vector2(300, 250)
	]
	
	if ghost_points.size() > 0:
		ghost_animation.position = ghost_points[0]

func _teleport_ghost_menu():
	# Teleport ghost to random point in menu for demo effect
	if ghost_points.size() > 0:
		current_ghost_point = randi() % ghost_points.size()
		var new_position = ghost_points[current_ghost_point]
		ghost_animation.position = new_position
		
		# Add a little animation effect
		var tween = create_tween()
		tween.tween_property(ghost_animation, "modulate:a", 0.3, 0.1)
		tween.tween_property(ghost_animation, "modulate:a", 1.0, 0.1)

func _on_ghost_gui_input(event):
	# Simulate flashlight pointing on ghost in menu
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		# Check if mouse is over ghost (simplified collision)
		var mouse_pos = get_viewport().get_mouse_position()
		var ghost_pos = ghost_animation.global_position
		var distance = mouse_pos.distance_to(ghost_pos)
		
		if distance < 50:  # Ghost hit detection
			_catch_ghost_demo()

func _catch_ghost_demo():
	# Demo version of catching ghost in menu
	score += 10
	_show_feedback("GHOST CAUGHT! +10 POINTS")
	
	# Show random meme quote
	var random_quote = meme_quotes[randi() % meme_quotes.size()]
	meme_quote.text = "\"" + random_quote + "\""
	meme_quote.visible = true
	
	# Update score display
	if score > best_score:
		best_score = score
		score_label.text = "Best Score: " + str(best_score)
		_save_best_score(best_score)
	
	# Play sound effect (if available)
	if music_player:
		music_player.pitch_scale = 1.2
		music_player.play()
	
	# Hide quote after delay
	await get_tree().create_timer(3.0).timeout
	meme_quote.visible = false

func _show_feedback(message):
	feedback_label.text = message
	feedback_label.visible = true
	
	# Add animation effect
	var original_scale = feedback_label.scale
	feedback_label.scale = Vector2(0.5, 0.5)
	var tween = create_tween()
	tween.tween_property(feedback_label, "scale", original_scale, 0.3).set_trans(Tween.TRANS_BOUNCE)
	
	# Hide after delay
	await get_tree().create_timer(2.0).timeout
	feedback_label.visible = false

func _on_play_pressed():
	_show_feedback("STARTING GAME...")
	await get_tree().create_timer(1.0).timeout
	
	# Load the main game scene
	var game_scene = preload("res://scenes/Game.tscn")
	if game_scene:
		get_tree().change_scene_to_packed(game_scene)

func _on_settings_pressed():
	_show_feedback("SETTINGS (Coming Soon)")

func _on_quit_pressed():
	_show_feedback("QUITTING...")
	await get_tree().create_timer(1.0).timeout
	get_tree().quit()

func _load_best_score():
	# Simple score loading (in real game, use proper save system)
	var save_file = FileAccess.open("user://best_score.save", FileAccess.READ)
	if save_file:
		var score_data = save_file.get_as_text()
		save_file.close()
		return score_data.to_int()
	return 0

func _save_best_score(score_to_save):
	# Simple score saving
	var save_file = FileAccess.open("user://best_score.save", FileAccess.WRITE)
	if save_file:
		save_file.store_string(str(score_to_save))
		save_file.close()
