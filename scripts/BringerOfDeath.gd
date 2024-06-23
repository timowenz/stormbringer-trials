extends CharacterBody2D

const SPEED = 150
const GRAVITY = 25
const JUMP_HEIGHT = 400
var health = 100
var player = null
var player_chase = false
var damage = 15
signal dead

@onready var animation = $AnimatedSprite2D
@onready var healthbar = $HealthBar

func _ready():
	healthbar.init_health(health)

func move_enemy_towards_player():
	velocity.y += GRAVITY
	var direction = (player.position - position).normalized()
	velocity.x = direction.x * SPEED

	if (player.position.x < position.x):
		$AnimatedSprite2D.flip_h = false
		$AnimatedSprite2D.offset.x = 0
		$Node2D.scale.x = 1
	else:
		$AnimatedSprite2D.flip_h = true
		# This is because the sprite: 'BringerOfDeath' is not centered
		$AnimatedSprite2D.offset.x = 60
		$Node2D.scale.x = -1
	move_and_slide()

func _physics_process(_delta):
	if (player_chase):
		move_enemy_towards_player()

		# attack player
		if (player.position.distance_to(position) < 50 and $AnimatedSprite2D.animation != "hurt"):
			$AnimatedSprite2D.play("attack")
		elif ($AnimatedSprite2D.animation != "hurt" and $AnimatedSprite2D.animation != "attack"):
			$AnimatedSprite2D.play("walk")
	
func _on_detection_area_2d_body_entered(body):
	player = body
	player_chase = true

func get_health():
	return health

func set_health(value):
	health = value

func take_damage(dmg):
	health -= dmg
	healthbar.health = health
	if (health <= 0):
		dead.emit()
		queue_free()

func _on_area_2d_body_entered(body):
	# jump
	if (body.name == "TileMap"):
		velocity.y = -JUMP_HEIGHT

func _on_animated_sprite_2d_animation_finished():
	if ($AnimatedSprite2D.animation == "hurt" and player.position.distance_to(position) < 50):
		$AnimatedSprite2D.play("attack")
	elif ($AnimatedSprite2D.animation == "attack"):
		$AnimatedSprite2D.play("attack")
		player.take_damage(damage)
