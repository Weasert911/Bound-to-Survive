extends CharacterBody3D
class_name Ghost

@export_category("Player")
@export var player_path: NodePath
@onready var player: Node3D = get_node_or_null(player_path)

@export_category("Movement")
@export var ghost_points: Array[Marker3D]
@export var move_speed: float = 1.2
@export var float_height: float = 0.25
@export var float_speed: float = 1.2
@export var float_noise: float = 0.03

@export var min_wait_at_point: float = 1.5
@export var max_wait_at_point: float = 3.5

@export_category("Look")
@export var look_speed: float = 3.0

@export_category("Flashlight")
@export var scream_audio: AudioStreamPlayer3D
@export var max_flashlight_hits: int = 4
@export var stun_times := [1.0, 0.6, 0.3, 0.0]
@export var score_per_hit: int = 25
@export var score_multiplier: float = 2.0

@export_category("Attacks")
@export var proximity_attack_radius: float = 2.5
@export var proximity_damage: float = 20.0

@export var fake_attack_chance: float = 0.2
@export var scream_stun_damage: float = 10.0

@export_category("Shader")
@export var shader_node_path: NodePath
@export var burn_multiplier: float = 1.0
@export var pulse_multiplier: float = 1.0

var shader_material: ShaderMaterial = null

var base_y: float = 0.0
var time_accum: float = 0.0
var target_point: Marker3D = null

var waiting := false
var screaming := false
var flashlight_hits := 0
var aggression: float = 0.0
var attacking := false

var dna_shape: float
var dna_distortion: float
var dna_flicker: float
var dna_opacity: float

func _ready():
	randomize()
	base_y = global_position.y
	_generate_dna()
	_pick_new_point()

	# Add ghost to the "ghost" group for flashlight detection
	add_to_group("ghost")

	var node = get_node_or_null(shader_node_path)
	if node and node.material is ShaderMaterial:
		shader_material = node.material

func _process(delta):
	if not movement_enabled:
		return

	time_accum += delta

	_float_motion()
	_face_player(delta)
	_move(delta)
	_update_shader()
	_check_proximity_attack()

var movement_enabled := true

func set_movement_enabled(enabled: bool):
	movement_enabled = enabled
	if not enabled:
		velocity = Vector3.ZERO
		set_physics_process(false)
	else:
		set_physics_process(true)

func on_flashlight_hit():
	if screaming:
		return

	screaming = true
	flashlight_hits = min(flashlight_hits + 1, max_flashlight_hits)
	aggression += 0.25

	move_speed += 0.25
	float_speed += 0.15

	_teleport_to_next_point()
	_trigger_flashlight_hit_feedback()

	var score_to_add = int(score_per_hit * score_multiplier)
	_add_score(score_to_add)

	if scream_audio:
		scream_audio.pitch_scale = 1.0 + aggression * 0.3
		scream_audio.play()

	var stun_time: float = stun_times[flashlight_hits - 1]

	if player and player.has_method("take_damage"):
		player.take_damage(scream_stun_damage)

	if stun_time > 0.0:
		await get_tree().create_timer(stun_time).timeout

	if scream_audio:
		await scream_audio.finished

	screaming = false

func _add_score(amount: int):
	var player_hud = get_tree().get_first_node_in_group("player_hud")
	if player_hud and player_hud.has_method("add_score"):
		player_hud.add_score(amount)

	var game_manager = get_tree().get_first_node_in_group("game_manager")
	if game_manager and game_manager.has_method("add_score"):
		game_manager.add_score(amount)

func _float_motion():
	var y_offset := sin(time_accum * float_speed) * float_height
	var noise := sin(time_accum * 3.1 * dna_flicker) * float_noise

	var pos := global_position
	pos.y = base_y + y_offset + noise
	global_position = pos

func _face_player(delta):
	if player == null:
		return

	var dir := player.global_position - global_position
	dir.y = 0.0

	if dir.length() < 0.01:
		return

	var target_yaw := atan2(dir.x, dir.z)
	rotation.y = lerp_angle(
		rotation.y,
		target_yaw,
		delta * look_speed * (1.0 + aggression)
	)

func _move(delta):
	if target_point == null or waiting or screaming:
		return

	var dir := target_point.global_position - global_position
	dir.y = 0.0

	if dir.length() < 0.2:
		waiting = true
		await get_tree().create_timer(randf_range(min_wait_at_point, max_wait_at_point)).timeout
		waiting = false
		_pick_new_point()
		return

	if randf() < 0.01 + aggression * 0.02:
		global_position += Vector3(
			randf_range(-0.4, 0.4),
			0.0,
			randf_range(-0.4, 0.4)
		)

	global_position += dir.normalized() * move_speed * delta

func _check_proximity_attack():
	if attacking or player == null:
		return

	var dist := global_position.distance_to(player.global_position)

	if dist < proximity_attack_radius:
		attacking = true

		if randf() < fake_attack_chance:
			if player.has_method("fake_damage_feedback"):
				player.fake_damage_feedback()
		else:
			if player.has_method("take_damage"):
				player.take_damage(proximity_damage)

		await get_tree().create_timer(1.2).timeout
		attacking = false

func _pick_new_point():
	if ghost_points.is_empty():
		return
	target_point = ghost_points.pick_random()

func _teleport_to_next_point():
	# Pick a new random point from the ghost points array
	if ghost_points.is_empty():
		return
	
	var new_target_point = ghost_points.pick_random()
	
	# Teleport the ghost to the new point's position
	if new_target_point:
		var new_position = new_target_point.global_position
		# Keep the same Y height as the base position
		new_position.y = base_y
		global_position = new_position
		
		# Update the target point for future movement
		target_point = new_target_point
		waiting = false

func _trigger_flashlight_hit_feedback():
	# Find the flashlight node in the scene and trigger hit feedback
	var flashlight_node = get_tree().get_first_node_in_group("flashlight")
	if flashlight_node and flashlight_node.has_method("trigger_hit_feedback"):
		flashlight_node.trigger_hit_feedback()

func _generate_dna():
	dna_shape = randf_range(0.6, 1.6)
	dna_distortion = randf_range(0.5, 2.0)
	dna_flicker = randf_range(0.6, 2.5)
	dna_opacity = randf_range(0.45, 0.95)

func _update_shader():
	if shader_material == null or player == null:
		return

	var dist := global_position.distance_to(player.global_position)
	var d := dist / 4.0

	var intensity: float = clamp(1.0 - (d * d), 0.0, 1.0)
	intensity *= (1.0 + aggression)

	shader_material.set_shader_parameter("mint_burn", intensity * burn_multiplier)
	shader_material.set_shader_parameter(
		"pulse_speed",
		(1.5 + intensity) * pulse_multiplier * dna_flicker
	)

	shader_material.set_shader_parameter("distortion_strength", intensity * dna_distortion)
	shader_material.set_shader_parameter("shape_warp", dna_shape)
	shader_material.set_shader_parameter("alpha_cut", dna_opacity - intensity * 0.35)
