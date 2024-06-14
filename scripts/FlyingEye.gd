class_name Enemy
extends CharacterBody2D

const SPEED = 200
var health = 60
var player = null
var player_chase = false
var damage = 20
@onready var healthbar = $HealthBar

func _ready():
	healthbar.init_health(health)

func _physics_process(_delta):
	if (player_chase):

		position += (player.position - position) / SPEED

		if (player.position.x < position.x):
			$AnimatedSprite2D.flip_h = true
		else:
			$AnimatedSprite2D.flip_h = false
		
		if (player.position.distance_to(position) < 50):
			$AnimatedSprite2D.play("attack")
		else:
			$AnimatedSprite2D.play("flight")

func _on_detection_area_2d_body_entered(body):
	player = body
	player_chase = true

func get_health():
	return health

func set_health(value):
	health = value

func take_damage(damage):
	health -= damage
	healthbar.health = health
	if (health <= 0):
		queue_free()

func _on_animated_sprite_2d_animation_finished():
	if player.health <= 0:
		player = null
		player_chase = false
	else:
		player.take_damage(damage)
