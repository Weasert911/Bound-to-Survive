extends AnimatedSprite2D

@onready var holder: Control =$".."
@onready var sprite: AnimatedSprite2D = $"."

@export var flashlight_light: SpotLight3D
@export var battery_percent := 1.0

@export var low_battery_threshold := 0.3

@export var ui_material: ShaderMaterial
@export var ui_distress_when_low := 0.5
@export var ui_distress_when_hit := 0.8

var current_state := -1
var hit_feedback_active := false
var hit_feedback_timer := 0.0
var hit_feedback_duration := 0.3

func _ready():
	holder.position = holder.position.round()
	sprite.position = sprite.position.round()
	sprite.play("state")
	_update_state(true)

func _process(_delta):
	_update_state(true)
	
	# Handle hit feedback timer
	if hit_feedback_active:
		hit_feedback_timer += _delta
		if hit_feedback_timer >= hit_feedback_duration:
			hit_feedback_active = false
			hit_feedback_timer = 0.0
			_update_ui_shader()

func _update_state(force := false):
	var new_state := _calculate_state()

	if new_state == current_state and not force:
		return

	current_state = new_state
	sprite.frame = current_state

	_update_ui_shader()

func _calculate_state() -> int:
	if not flashlight_light:
		return 2

	if not flashlight_light.visible or battery_percent <= 0.0:
		return 2

	if battery_percent <= low_battery_threshold:
		return 1

	return 0


func _update_ui_shader():
	if not ui_material:
		return

	var distress := 0.0
	
	# Apply hit feedback distress if active
	if hit_feedback_active:
		distress = ui_distress_when_hit
	else:
		# Normal state-based distress
		if current_state == 1:
			distress = ui_distress_when_low
		elif current_state == 2:
			distress = 1.0

	ui_material.set_shader_parameter("ui_distress", distress)

func trigger_hit_feedback():
	hit_feedback_active = true
	hit_feedback_timer = 0.0
	# Immediately apply the hit feedback distress
	if ui_material:
		ui_material.set_shader_parameter("ui_distress", ui_distress_when_hit)
