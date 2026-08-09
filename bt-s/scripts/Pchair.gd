extends Node3D
var input_enabled := true

func set_input_enabled(value: bool) -> void:
	input_enabled = value


@export var mouse_sensitivity: float = 0.1
@export var min_pitch: float = -30.0
@export var max_pitch: float = 60.0
@export var look_smoothness: float = 8.0

@export var flashlight_min_on_time: float = 0.6
@export var flashlight_cooldown_time: float = 1.2
@export var flashlight_activation_delay: float = 0.1
@export var flashlight_auto_off_time: float = 2.0

@export var breath_speed: float = 1.2
@export var breath_strength: float = 0.015
@export var fear_breath_multiplier: float = 1.6

@export var sway_speed: float = 0.8
@export var sway_strength: float = 0.3

@export var tremor_strength: float = 0.15
@export var tremor_speed: float = 18.0

@export var aim_drift_strength: float = 0.15

@export var ray_length: float = 100.0
@export var debug_print: bool = false

@export var flashlight_light: SpotLight3D
@export var flashlight_model: Node3D

@onready var timer: Timer = $"../../Timer"
@onready var fsfx: AudioStreamPlayer3D = $"../../music & Sfx/AudioStreamPlayer3D"
@onready var flash_ray: RayCast3D = $Camera3D/RayCast3D

@onready var pivot: Node3D = self
@onready var cam: Camera3D = $Camera3D

var yaw := 0.0
var pitch := 0.0
var target_yaw := 0.0
var target_pitch := 0.0

var flashlight_on := false
var flashlight_active := false
var can_toggle_flashlight := true
var auto_off_timer := 0.0
var controls_disabled := false

var _time := 0.0
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	DisplayServer.window_set_size(Vector2i(1173, 660))
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	flash_ray.enabled = false
	flash_ray.target_position = Vector3(0, 0, -ray_length)
	
	# Add this node to the flashlight group so ghosts can find it
	add_to_group("flashlight")
	
func _input(event):
	if event.is_action_pressed("flashlight_toggle") and can_toggle_flashlight:
		if flashlight_on:
			_turn_flashlight_off()
		else:
			_turn_flashlight_on()

	if event is InputEventMouseMotion:
		var resistance := 0.25 if flashlight_on else 1.0

		target_yaw -= event.relative.x * mouse_sensitivity * resistance
		target_pitch -= event.relative.y * mouse_sensitivity * resistance
		target_pitch = clamp(target_pitch, min_pitch, max_pitch)
func _turn_flashlight_on():
	flashlight_on = true
	can_toggle_flashlight = false
	flashlight_active = false

	target_yaw = yaw
	target_pitch = pitch

	timer.start(flashlight_activation_delay)
func _turn_flashlight_off():
	flashlight_on = false
	can_toggle_flashlight = false
	flashlight_active = false

	flashlight_light.visible = false
	flash_ray.enabled = false
	fsfx.play()

	# Re-enable controls when flashlight turns off
	if controls_disabled:
		controls_disabled = false
		set_input_enabled(true)

	timer.start(flashlight_cooldown_time)
func _on_timer_timeout() -> void:
	if flashlight_on and not flashlight_active:
		flashlight_active = true
		flashlight_light.visible = true
		flash_ray.enabled = true
		fsfx.play()

		# Start auto-off timer when flashlight becomes active
		auto_off_timer = 0.0
		controls_disabled = true
		set_input_enabled(false)
		
		timer.start(flashlight_min_on_time)
	else:
		can_toggle_flashlight = true
func _process(delta):
	_time += delta

	# Handle auto-off timer
	if flashlight_active and controls_disabled:
		auto_off_timer += delta
		if auto_off_timer >= flashlight_auto_off_time:
			_turn_flashlight_off()

	var drift_strength := aim_drift_strength if flashlight_on else aim_drift_strength * 0.3
	var drift := sin(_time * 0.4) * drift_strength

	yaw = lerp(yaw, target_yaw + drift, delta * look_smoothness)
	pitch = lerp(pitch, target_pitch, delta * look_smoothness)

	pivot.rotation_degrees.x = pitch
	rotation_degrees.y = yaw

	var breath_mult := fear_breath_multiplier if flashlight_on else 1.0
	var breath := sin(_time * breath_speed) * breath_strength * breath_mult
	cam.position.y = breath

	var sway := sin(_time * sway_speed) * sway_strength
	cam.rotation_degrees.z = sway

	if flashlight_on:
		cam.rotation_degrees.x += sin(_time * tremor_speed) * tremor_strength
func _physics_process(delta):
	if not flashlight_active:
		return

	flash_ray.force_raycast_update()

	if debug_print:
		print("Ray hit:", flash_ray.is_colliding())

	if flash_ray.is_colliding():
		var hit = flash_ray.get_collider()
		if hit and hit.is_in_group("ghost"):
			hit.on_flashlight_hit()
