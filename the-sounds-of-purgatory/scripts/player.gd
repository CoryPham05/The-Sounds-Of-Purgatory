extends CharacterBody2D

signal health_change(current_hp: float, max_hp: float)
signal death

@export var speed: float = 250.0
@export var dash_speed: float = 600.0
@export var dash_duration: float = 0.15

@export var max_hp: float = 100.0
@export var attack_rate: float = 0.25
@export var projectile_scene: PackedScene

var hp: float
var is_dashing: bool = false
var dash_timer: float = 0.0
var attack_cd: float = 0.0


func _ready() -> void:
	hp = max_hp
	health_change.emit(hp, max_hp)


func _physics_process(delta: float) -> void:
	# Dash timing
	if is_dashing:
		dash_timer -= delta
		if dash_timer <= 0.0:
			is_dashing = false
			
	if attack_cd > 0.0:
		attack_cd -= delta

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
	var mouse_pos := get_global_mouse_position()
	$Sprite2D/Aim.look_at(mouse_pos)
	$Sprite2D.flip_h = mouse_pos.x < global_position.x
	
	# Attack
	if Input.is_action_pressed("attack") and attack_cd <= 0.0:
		shoot()


func shoot() -> void:
	if not projectile_scene:
		return

	attack_cd = attack_rate
	var bullet := projectile_scene.instantiate()
	bullet.global_transform = $Sprite2D/Aim/Muzzle.global_transform
	get_tree().current_scene.add_child(bullet)


func take_damage(damage: float) -> void:
	hp = clampf(hp - damage, 0.0, max_hp)
	health_change.emit(hp, max_hp)
	if hp <= 0.0:
		death.emit()
		queue_free()
