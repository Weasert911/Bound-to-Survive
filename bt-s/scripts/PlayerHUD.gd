extends CanvasLayer

signal game_over

@export var match_duration: float = 90.0
@export var show_minutes := true

@export var state_1_until: float = 30.0
@export var state_2_until: float = 55.0
@export var state_3_until: float = 10.0

@export var frame_state_1: Texture2D
@export var frame_state_2: Texture2D
@export var frame_state_3: Texture2D
@export var frame_state_4: Texture2D

@export var post_process_material: ShaderMaterial

@export var shader_intensity_state_1 := 0.05
@export var shader_intensity_state_2 := 0.15
@export var shader_intensity_state_3 := 0.35
@export var shader_intensity_state_4 := 0.60

@export var ui_distress_state_1 := 0.05
@export var ui_distress_state_2 := 0.18
@export var ui_distress_state_3 := 0.40
@export var ui_distress_state_4 := 0.75

@onready var timer_frame: TextureRect = $SafeArea/TopCenter/TimerFrame
@onready var timer_label: Label = $SafeArea/TopCenter/TimerLabel
@onready var score_label: Label = $SafeArea/TopCenter/ScoreLabel

var time_left: float
var current_state := -1
var current_score := 0

func _ready():
	time_left = match_duration
	_update_timer_text()
	_update_timer_state()

	# Add to player_hud group for score updates from ghost
	add_to_group("player_hud")

func _process(delta):
	if time_left <= 0.0:
		_trigger_game_over()
		return

	time_left = max(0.0, time_left - delta)
	_update_timer_text()
	_update_timer_state()

func _update_timer_state(force := false):
	var elapsed := match_duration - time_left
	var new_state := 4

	if elapsed <= state_1_until:
		new_state = 1

	elif elapsed <= state_2_until:
		new_state = 2

	elif time_left > state_3_until:
		new_state = 3

	else:
		new_state = 4

	if new_state != current_state or force:
		current_state = new_state
		_apply_state(current_state)

func _apply_state(state: int):
	match state:
		1:
			timer_frame.texture = frame_state_1
			_set_post_fx(shader_intensity_state_1)
			_set_ui_distress(ui_distress_state_1)

		2:
			timer_frame.texture = frame_state_2
			_set_post_fx(shader_intensity_state_2)
			_set_ui_distress(ui_distress_state_2)

		3:
			timer_frame.texture = frame_state_3
			_set_post_fx(shader_intensity_state_3)
			_set_ui_distress(ui_distress_state_3)

		4:
			timer_frame.texture = frame_state_4
			_set_post_fx(shader_intensity_state_4)
			_set_ui_distress(ui_distress_state_4)

func _set_post_fx(value: float):
	if post_process_material:
		post_process_material.set_shader_parameter("global_strength", value)

func _set_ui_distress(value: float):
	if timer_frame.material and timer_frame.material is ShaderMaterial:
		timer_frame.material.set_shader_parameter("distress", value)

func _update_timer_text():
	var seconds := int(ceil(time_left))

	if show_minutes:
		var m := seconds / 60
		var s := seconds % 60
		timer_label.text = "%02d:%02d" % [m, s]
	else:
		timer_label.text = str(seconds)

func _trigger_game_over():
	timer_label.text = "TIME'S UP"
	timer_frame.texture = frame_state_4
	_set_post_fx(shader_intensity_state_4)
	_set_ui_distress(ui_distress_state_4)
	emit_signal("game_over")

func add_score(amount: int):
	current_score += amount
	_update_score_text()
	_show_score_feedback(amount)

func _update_score_text():
	score_label.text = "SCORE: " + str(current_score)

func _show_score_feedback(amount: int):
	var feedback_label = Label.new()
	feedback_label.text = "+" + str(amount) + " POINTS!"
	feedback_label.add_theme_font_override("font", score_label.get_theme_font("font"))
	feedback_label.add_theme_font_size_override("font_size", score_label.get_theme_font_size("font_size"))
	feedback_label.add_theme_color_override("font_color", Color(1, 1, 0))
	feedback_label.position = score_label.position + Vector2(0, -50)
	feedback_label.modulate.a = 0.0

	$SafeArea/TopCenter.add_child(feedback_label)

	var tween = create_tween()
	tween.tween_property(feedback_label, "modulate:a", 1.0, 0.2)
	tween.tween_property(feedback_label, "position:y", feedback_label.position.y - 30, 0.5)
	tween.tween_property(feedback_label, "modulate:a", 0.0, 0.5).set_delay(0.5)
	tween.tween_callback(feedback_label.queue_free)
