extends CharacterBody2D

const SPEED = 200
var health = 200
var player = null
var player_chase = false
var projectile_instance = preload ("res://scenes/Projectile.tscn")
signal dead
@onready var healthbar = $HealthBar
const vulnerable = "lightning"
const resistance = "arcane"
@onready var projectileCD = $ProjectileCD
@onready var anim = $AnimatedSprite2D
const ENEMEY_DAMAGE = 15

func _ready():
	healthbar.init_health(health)

func _physics_process(_delta):
	if (player_chase):

		position += (player.position - position) / SPEED

		if (player.position.x < position.x):
			$AnimatedSprite2D.flip_h = true
		else:
			$AnimatedSprite2D.flip_h = false
		
		if (player.position.distance_to(position) < 150 && projectileCD.time_left == 10):
			anim.play("attack")
			# stop chasing
			player_chase = false
			
			
		else:
			anim.play("flight")
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
	healthbar.health = health
	if (health <= 0):
		# if nightborn dies and necromancer is health <= 0, player wins

		if (!is_instance_valid( %Nightborn)):
			%Player.can_win = true
		dead.emit()
		queue_free()

func _on_animated_sprite_2d_animation_finished():
	player_chase = true
	if anim.animation == "dead":
		queue_free()

func _on_projectile_cd_timeout():
	var projectile = projectile_instance.instantiate()
	add_child(projectile)


func _on_area_2d_body_entered(body):
	if body.name == "Player":
		anim.play("attack")
		player.take_damage(ENEMEY_DAMAGE)
