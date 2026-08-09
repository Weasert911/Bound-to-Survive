extends Control

@export var tutorial_messages: Array[String] = [
	"YOU ARE TRAPPED ON A CHAIR",
	"USE MOUSE TO LOOK AROUND", 
	"PRESS 'F' TO USE FLASHLIGHT",
	"FLASHLIGHT HAS A COOLDOWN",
	"THE GHOST HATES LIGHT",
	"STAY AWAY FROM THE GHOST",
	"YOU MUST SURVIVE 90 SECONDS"
]

@export var popup_duration: float = 2.5
@export var fade_duration: float = 0.5
@export var message_spacing: float = 0.3

@onready var message_label: Label = $MessageLabel
@onready var overlay_bg: ColorRect = $OverlayBG

var current_message_index := 0
var is_active := false

func _ready():
	visible = false
	overlay_bg.modulate = Color(0, 0, 0, 0)
	message_label.modulate = Color(1, 1, 1, 0)

func show_tutorial():
	if is_active:
		return
	
	is_active = true
	visible = true
	current_message_index = 0
	
	await show_next_message()

func show_next_message():
	if current_message_index >= tutorial_messages.size():
		hide_tutorial()
		return
	
	var message = tutorial_messages[current_message_index]
	message_label.text = message
	
	# Fade in
	var tween = create_tween()
	tween.tween_property(overlay_bg, "modulate:a", 0.8, fade_duration)
	tween.tween_property(message_label, "modulate:a", 1.0, fade_duration)
	await tween.finished
	
	# Wait for duration
	await get_tree().create_timer(popup_duration).timeout
	
	# Fade out
	tween = create_tween()
	tween.tween_property(overlay_bg, "modulate:a", 0.0, fade_duration)
	tween.tween_property(message_label, "modulate:a", 0.0, fade_duration)
	await tween.finished
	
	current_message_index += 1
	
	# Wait between messages
	await get_tree().create_timer(message_spacing).timeout
	
	await show_next_message()

func hide_tutorial():
	is_active = false
	visible = false
	overlay_bg.modulate = Color(0, 0, 0, 0)
	message_label.modulate = Color(1, 1, 1, 0)