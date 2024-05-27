extends CharacterBody2D

const SPEED = 200
const GRAVITY = 100
const JUMP = 300
var health = 100
var player = null
var player_chase = false

func _ready():
	pass

func _physics_process(delta):
	velocity.y += delta * GRAVITY
	var motion = velocity * delta
	move_and_collide(motion)

	if (player_chase):
		position += (player.position - position) / SPEED

func _on_detection_area_2d_body_entered(body):
	player = body
	player_chase = true

func _on_detection_area_2d_body_exited(_body):
	player = null
	player_chase = false

func get_health():
	return health

func set_health(value):
	health = value

func take_damage(damage):
	health -= damage
	if (health <= 0):
		queue_free()