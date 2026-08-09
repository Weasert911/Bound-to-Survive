extends CanvasLayer

@export var lines := [
	"YOU ARE NOT ALONE.",
	"IT HATES THE LIGHT.",
	"DON'T LOOK AWAY.",
	"SURVIVE."
]

@export var fade_in_time := 0.4
@export var hold_time := 1.2
@export var fade_out_time := 0.3
@export var time_between_lines := 0.2

@onready var label: Label = $Blackbg/Label

var tween: Tween

func _ready():
	disable_player()
	play_sequence()

func play_sequence() -> void:
	for line in lines:
		await show_line(line)
	end_intro()

func show_line(text: String) -> void:
	label.text = text
	label.modulate.a = 0.0

	tween = create_tween()
	tween.tween_property(label, "modulate:a", 1.0, fade_in_time)
	await tween.finished

	await get_tree().create_timer(hold_time).timeout

	tween = create_tween()
	tween.tween_property(label, "modulate:a", 0.0, fade_out_time)
	await tween.finished

	await get_tree().create_timer(time_between_lines).timeout

func end_intro() -> void:
	enable_player()
	# Notify the game manager that intro is complete
	var game_manager = get_tree().get_first_node_in_group("game_manager")
	if game_manager:
		game_manager._on_intro_complete()
	queue_free()

func disable_player():
	get_tree().call_group("player", "set_input_enabled", false)

func enable_player():
	get_tree().call_group("player", "set_input_enabled", true)
