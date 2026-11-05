extends CharacterBody2D


@export var speed: float = 250.0
@export var dash_speed: float = 600.0
@export var dash_duration: float = 0.15

var is_dashing: bool = false
var dash_timer: float = 0.0


func _physics_process(delta: float) -> void:
	# Dash timing
	if is_dashing:
		dash_timer -= delta
		if dash_timer <= 0.0:
			is_dashing = false

	# Directional Input (WASD)
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")

	# Dash
	if Input.is_action_just_pressed("dash") and not is_dashing and input_dir != Vector2.ZERO:
		is_dashing = true
		dash_timer = dash_duration

	# Velocity
	var current_speed = dash_speed if is_dashing else speed
	if input_dir != Vector2.ZERO:
		velocity = input_dir.normalized() * current_speed
	else:
		velocity = Vector2.ZERO

	move_and_slide()
	
	# Cursor
	look_at(get_global_mouse_position())
