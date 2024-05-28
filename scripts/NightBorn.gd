extends CharacterBody2D

const SPEED = 150
const GRAVITY = 25
const JUMP_HEIGHT = 400
var health = 100
var player = null
var player_chase = false

func _physics_process(_delta):
	velocity.y += GRAVITY

	if (player_chase):

		var direction = (player.position - position).normalized()
		velocity.x = direction.x * SPEED

		if (player.position.x < position.x):
			$AnimatedSprite2D.flip_h = true
			$Node2D.scale.x = 1
		else:
			$AnimatedSprite2D.flip_h = false
			$Node2D.scale.x = -1
		
		if (player.position.distance_to(position) < 50):
			$AnimatedSprite2D.play("attack")
		else:
			$AnimatedSprite2D.play("walk")
	move_and_slide()

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

func _on_area_2d_body_entered(body):
	# jump
	if (body.name == "TileMap"):
		velocity.y = -JUMP_HEIGHT
