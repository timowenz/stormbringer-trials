extends CharacterBody2D

const SPEED = 150
const GRAVITY = 25
const JUMP_HEIGHT = 400
var health = 200
var player = null
var player_chase = false
var damage = 15
signal dead
@onready var healthbar = $HealthBar

func _ready():
	healthbar.init_health(health)

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
	healthbar.health = health
	if (health <= 0):
		dead.emit()
		queue_free()

func _on_animated_sprite_2d_animation_finished():
	if (scale == Vector2(1.5, 1.5)):
		player.take_damage(damage + 10)
	else:
		player.take_damage(damage)

func _on_area_2d_body_entered(body):
	# jump
	if (body.name == "TileMap"):
		velocity.y = -JUMP_HEIGHT

func _on_big_timer_timeout():
	scale = Vector2(1.5, 1.5)

func _on_small_timer_timeout():
	scale = Vector2(1, 1)
