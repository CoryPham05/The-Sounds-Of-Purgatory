extends Node2D

@export var enemy_scene: PackedScene
@export var spawn_dist: float = 650.0
@export var wave_timer: float = 10.0 

var time_remaining: float

@onready var player: CharacterBody2D = $Player
@onready var health: Label = $HUD/HealthLabel
@onready var timer_label: Label = $HUD/TimerLabel

func _ready() -> void:
	time_remaining = wave_timer
	$SpawnTimer.timeout.connect(timeout)
	
	if is_instance_valid(player):
		player.health_change.connect(health_change)
		player.death.connect(dead)
		health_change(player.hp, player.max_hp)

func _process(delta: float) -> void:
	if time_remaining > 0.0 and is_instance_valid(player):
		time_remaining = maxf(0.0, time_remaining - delta)
		update_timer_ui()
		
		if time_remaining == 0.0:
			wave_finish()

func timeout() -> void:
	var enemy := enemy_scene.instantiate()
	var random_angle := randf() * TAU
	var spawn_diff := Vector2.RIGHT.rotated(random_angle) * spawn_dist
	enemy.global_position = player.global_position + spawn_diff
	add_child(enemy)

func health_change(current_hp: float, max_hp: float) -> void:
	health.text = "HP: %d / %d" % [current_hp, max_hp]

func update_timer_ui() -> void:
	var total_seconds := ceili(time_remaining)
	var minutes := floori(total_seconds / 60.0)
	var seconds := total_seconds % 60
	timer_label.text = "Survive: %02d:%02d" % [minutes, seconds]

func dead() -> void:
	$SpawnTimer.stop()
	timer_label.text = "YOU DIED"

func wave_finish() -> void:
	$SpawnTimer.stop()
	get_tree().call_group("enemies", "queue_free")
	timer_label.text = "WAVE COMPLETE!"
