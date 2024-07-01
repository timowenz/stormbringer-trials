extends CharacterBody2D

enum State {IDLE, WALK, ATTACK, DEAD, HIT, CAST}

const SPEED = 100
const GRAVITY = 25
const JUMP_HEIGHT = 400
const ENEMEY_DAMAGE = 15
var health = 100
var state = State.IDLE
var player = null
var player_chase = false

@onready var anim = $AnimatedSprite2D
@onready var healthbar = $HealthBar
@onready var spell = preload ("res://scenes/BringerOfDeath/Spell.tscn").instantiate()
@onready var attack_audio = $AttackAudio
@onready var cast_audio = $CastAudio

func _ready():
  set_state(State.IDLE)
  healthbar.init_health(health)

func _physics_process(delta):
  match state:
    State.IDLE:
      idle_state(delta)
    State.WALK:
      walk_state(delta)
    State.ATTACK:
      attack_state(delta)
    State.CAST:
      cast_state(delta)
    State.HIT:
      hit_state(delta)

func hit_state(_delta):
  if (health <= 0):
    set_state(State.DEAD)
  else:
    set_state(State.WALK)

func set_state(new_state):
  state = new_state
  match state:
    State.IDLE:
      anim.play("idle")
    State.WALK:
      anim.play("walk")
    State.ATTACK:
      anim.play("attack")
    State.HIT:
      anim.play("hit")
    State.DEAD:
      anim.play("dead")
    State.CAST:
      anim.play("cast")

func cast_state(_delta):
  if (!spell):
    spell = preload ("res://scenes/BringerOfDeath/Spell.tscn").instantiate()
  spell.position = player.position
  spell.offset = Vector2i(15, -27)
  if (player.position.distance_to(position) < 200):
    if (anim.frame == 0):
      cast_audio.play()
      get_parent().add_child(spell)
    set_state(State.CAST)

func attack_state(_delta):
  if (player.position.distance_to(position) < 50):
    if (anim.frame == 4):
      attack_audio.play()
    set_state(State.ATTACK)
  elif (player.position.distance_to(position) < 200):
    set_state(State.CAST)
  else:
    set_state(State.WALK)

func walk_state(_delta):
  var direction = (player.position - position).normalized()
  velocity.y += GRAVITY
  velocity.x = direction.x * SPEED

  if (player.position.x < position.x):
    $AnimatedSprite2D.flip_h = false
    $AnimatedSprite2D.offset.x = 0
    $Node2D.scale.x = 1
  else:
		# This is because the sprite: 'BringerOfDeath' is not centered
    $AnimatedSprite2D.flip_h = true
    $AnimatedSprite2D.offset.x = 70
    $Node2D.scale.x = -1

  if (player.position.distance_to(position) < 50):
    set_state(State.ATTACK)

  move_and_slide()

func idle_state(_delta):
  if (!player_chase):
    return set_state(State.IDLE)

  if (player.position.distance_to(position) < 50):
    set_state(State.ATTACK)
  else:
    set_state(State.WALK)

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

func _on_area_2d_body_entered(body):
  if (body.name == "TileMap"):
    velocity.y = -JUMP_HEIGHT

func _on_animated_sprite_2d_animation_finished():
  if anim.animation == "dead":
    queue_free()
  if anim.animation == "hit":
    set_state(State.WALK)
  if anim.animation == "attack":
    player.take_damage(ENEMEY_DAMAGE)
  if anim.animation == "cast":
    spell.queue_free()
    set_state(State.WALK)
    player.take_damage(ENEMEY_DAMAGE)