extends CharacterBody2D


@export var speed: float = 100.0
@export var max_hp: float = 50.0
@export var collision_damage: float = 10.0
@export var damage_interval: float = 0.5

var hp: float
var player: Node2D = null
var damage_cd: float = 0.0

@onready var hitbox: Area2D = get_node_or_null("Hitbox")

func _ready() -> void:
	hp = max_hp
	player = get_tree().get_first_node_in_group("player")


func _physics_process(delta: float) -> void:
	if is_instance_valid(player):
		var direction := global_position.direction_to(player.global_position)
		velocity = direction * speed
		move_and_slide()
	
	if damage_cd > 0.0:
		damage_cd -= delta
	elif hitbox:
		for body in hitbox.get_overlapping_bodies():
			if body.is_in_group("player") and body.has_method("take_damage"):
				body.take_damage(collision_damage)
				damage_cd = damage_interval
				break


func take_damage(damage: float) -> void:
	hp -= damage
	if hp <= 0.0:
		queue_free()
