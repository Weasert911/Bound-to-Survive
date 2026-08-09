extends Node3D

@onready var flashlight_ui := $PlayerHUD
@onready var player := $Chair/CameraPivot
@onready var ghost := $Ghost
@onready var intro := $IntroTextLayer
@export var game_duration := 90.0
@export var win_delay := 2.0

var game_state := "INTRO"
var game_timer := 0.0
var game_score := 0

func _ready():
	add_to_group("game_manager")

	flashlight_ui.game_over.connect(_on_game_over)

	_start_intro()

func _start_intro():
	game_state = "INTRO"

	if flashlight_ui:
		flashlight_ui.visible = false

func _on_intro_complete():
	game_state = "PLAYING"
	game_timer = 0.0

	if flashlight_ui:
		flashlight_ui.visible = true

	await get_tree().create_timer(0.1).timeout
	if player and player.has_method("set_input_enabled"):
		player.set_input_enabled(true)

func _process(delta):
	if game_state == "PLAYING":
		game_timer += delta

		if game_timer >= game_duration:
			_trigger_win()

func _on_game_over():
	if game_state != "PLAYING":
		return

	game_state = "GAME_OVER"

	if player and player.has_method("set_input_enabled"):
		player.set_input_enabled(false)

	if ghost and ghost.has_method("set_movement_enabled"):
		ghost.set_movement_enabled(false)

	await get_tree().create_timer(2.0).timeout
	_close_game()

func _trigger_win():
	if game_state == "WIN":
		return

	game_state = "WIN"

	if player and player.has_method("set_input_enabled"):
		player.set_input_enabled(false)

	if ghost and ghost.has_method("set_movement_enabled"):
		ghost.set_movement_enabled(false)

	await get_tree().create_timer(win_delay).timeout
	_close_game()

func _close_game():
	# Close the game completely after showing results
	get_tree().quit()

func _return_to_main_menu():
	var main_menu_path = "res://scripts/main.tscn"
	get_tree().change_scene_to_file(main_menu_path)

func restart_game():
	game_state = "INTRO"
	game_timer = 0.0
	game_score = 0
	_start_intro()

func restart_game_direct():
	# Restart game without intro (direct gameplay)
	game_state = "PLAYING"
	game_timer = 0.0
	game_score = 0

	if flashlight_ui:
		flashlight_ui.visible = true

	if player and player.has_method("set_input_enabled"):
		player.set_input_enabled(true)

	if ghost and ghost.has_method("set_movement_enabled"):
		ghost.set_movement_enabled(true)



func add_score(amount: int):
	game_score += amount
