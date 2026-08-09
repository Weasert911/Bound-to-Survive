extends Control

@onready var result_label: Label = $Panel/VBoxContainer/ResultLabel
@onready var score_label: Label = $Panel/VBoxContainer/ScoreLabel
@onready var quote_label: Label = $Panel/VBoxContainer/QuoteLabel
@onready var replay_button: Button = $Panel/VBoxContainer/ButtonContainer/ReplayButton
@onready var main_menu_button: Button = $Panel/VBoxContainer/ButtonContainer/MainMenuButton

@export var title_font: Font
@export var body_font: Font

# List of baiting quotes for different outcomes
var win_quotes := [
	"Impressive! But can you do it again?",
	"Lucky win! The ghost will be back...",
	"Skill or luck? Let's find out!",
	"Nice job! The spirits are restless...",
	"Victory! But the nightmare continues..."
]

var lose_quotes := [
	"You didn't stand a chance...",
	"The ghost always wins in the end...",
	"Better luck next time... if you dare...",
	"Fear consumes all... try again?",
	"The darkness claims another soul..."
]

var current_result := ""
var current_score := 0

func _ready():
	# Start hidden
	visible = false

	# Connect signals
	replay_button.pressed.connect(_on_replay_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)

func show_results(result_type: String, score: int):
	current_result = result_type
	current_score = score

	# Update UI
	if result_type == "WIN":
		result_label.text = "YOU SURVIVED!"
		result_label.add_theme_color_override("font_color", Color(0.2, 1, 0.2, 1))
		score_label.text = "FINAL SCORE: " + str(score)
		quote_label.text = _get_win_message(score)
	else:
		result_label.text = "GAME OVER"
		result_label.add_theme_color_override("font_color", Color(1, 0.2, 0.2, 1))
		score_label.text = "FINAL SCORE: " + str(score)
		quote_label.text = lose_quotes[randi() % lose_quotes.size()]

	# Show the result screen
	visible = true

func _get_win_message(score: int) -> String:
	# Determine win message based on score
	if score >= 100:
		return "PERFECT VICTORY! The ghost didn't stand a chance!"
	elif score >= 75:
		return "EXCELLENT! You dominated the ghost!"
	elif score >= 50:
		return "GREAT JOB! You survived with a solid score!"
	elif score >= 25:
		return "GOOD WORK! You made it through alive!"
	else:
		return "You survived... barely! Better luck next time!"

func _on_replay_pressed():
	# Find the game manager and restart without intro
	var game_manager = get_tree().get_nodes_in_group("game_manager")
	if game_manager.size() > 0:
		var game = game_manager[0]
		if game.has_method("restart_game_direct"):
			game.restart_game_direct()
		else:
			# Fallback to regular restart
			game.restart_game()

	# Hide result screen
	visible = false

func _on_main_menu_pressed():
	# Go back to main menu
	var main_menu_path = "res://scripts/main.tscn"
	get_tree().change_scene_to_file(main_menu_path)
