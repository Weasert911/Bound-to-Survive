extends AnimatedSprite2D

@export var cooldown_duration := 30.0
@export var total_fill_frames := 32
@export var reset_frame := 32
@export var reset_hold_time := 0.6

@onready var anim: AnimatedSprite2D = $"."

var frame_time := 0.0
var timer := 0.0
var frame_index := 0
var in_reset := false
var reset_timer := 0.0

func _ready():
	frame_time = cooldown_duration / total_fill_frames
	anim.play("cooldown")
	anim.frame = 0
	anim.position = anim.position.round()
	anim.scale = anim.scale.round()
	anim.offset = anim.offset.round()

func _process(delta):
	if in_reset:
		_process_reset(delta)
	else:
		_process_fill(delta)

func _process_fill(delta):
	timer += delta

	if timer >= frame_time:
		timer -= frame_time
		frame_index += 1

		if frame_index >= total_fill_frames:
			_enter_reset()
		else:
			anim.frame = frame_index

func _enter_reset():
	in_reset = true
	reset_timer = 0.0
	anim.frame = reset_frame
	_emit_ready()

func _process_reset(delta):
	reset_timer += delta
	if reset_timer >= reset_hold_time:
		_restart()

func _restart():
	in_reset = false
	timer = 0.0
	frame_index = 0
	anim.frame = 0

func _emit_ready():
	pass
