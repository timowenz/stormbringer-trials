extends CharacterBody2D

const SPEED = 200
var health = 200
var player = null
var player_chase = false
var projectile_instance = preload ("res://scenes/Projectile.tscn")
signal dead

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
			
			# create projectile
			var projectile = projectile_instance.instantiate()

			add_child(projectile)
			
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
		dead.emit()
		queue_free()

func _on_animated_sprite_2d_animation_finished():
	player_chase = true
