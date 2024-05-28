extends CharacterBody2D

const SPEED = 200
var health = 100
var player = null
var player_chase = false

func _physics_process(_delta):
	if (player_chase):

		position += (player.position - position) / SPEED

		if (player.position.x < position.x):
			$AnimatedSprite2D.flip_h = true
		else:
			$AnimatedSprite2D.flip_h = false
		
		if (player.position.distance_to(position) < 150):
			$AnimatedSprite2D.play("attack")
			# stop chasing
			player_chase = false
		else:
			$AnimatedSprite2D.play("flight")
			player_chase = true
func _on_detection_area_2d_body_entered(body):
	player = body
	player_chase = true

func get_health():
	return health

func set_health(value):
	health = value

func take_damage(damage):
	health -= damage
	if (health <= 0):
		queue_free()

func _on_animated_sprite_2d_animation_finished():
	player.take_damage(10)
	player_chase = true