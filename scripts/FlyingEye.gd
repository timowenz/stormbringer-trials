extends CharacterBody2D

enum State {FLIGHT, ATTACK, DEAD, HIT}

const SPEED = 100
const ENEMEY_DAMAGE = 15
var health = 100
var state = State.FLIGHT
var player = null
var player_chase = false

@onready var anim = $AnimatedSprite2D
@onready var healthbar = $HealthBar

func _ready():
  set_state(State.FLIGHT)
  healthbar.init_health(health)

func _physics_process(delta):
  match state:
    State.FLIGHT:
      flight_state(delta)
    State.ATTACK:
      attack_state(delta)

func set_state(new_state):
  state = new_state
  match state:
    State.FLIGHT:
      anim.play("flight")
    State.ATTACK:
      anim.play("attack")
    State.HIT:
      anim.play("hit")
    State.DEAD:
      anim.play("dead")

func attack_state(_delta):
  if (player.position.distance_to(position) < 50):
    set_state(State.ATTACK)
  else:
    set_state(State.FLIGHT)

func flight_state(_delta):
  if (player_chase):
    position += (player.position - position) / SPEED

    if (player.position.x < position.x):
      anim.flip_h = true
    else:
      anim.flip_h = false

    if (player.position.distance_to(position) < 50):
      set_state(State.ATTACK)
    else:
      set_state(State.FLIGHT)

  move_and_slide()

func _on_detection_area_2d_body_entered(body):
  player = body
  player_chase = true

func get_health():
  return health

func take_damage(damage):
  if (health <= 0):
    return set_state(State.DEAD)
  health -= damage
  healthbar.health = health
  set_state(State.HIT)

func _on_animated_sprite_2d_animation_finished():
  if anim.animation == "dead":
    queue_free()
  if anim.animation == "hit":
    set_state(State.FLIGHT)
  if anim.animation == "attack":
    player.take_damage(ENEMEY_DAMAGE)
