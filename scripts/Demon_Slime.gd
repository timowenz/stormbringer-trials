extends CharacterBody2D

enum State {IDLE, WALK, ATTACK, DEAD, HIT, CAST, SMASH, FIRE_BREATH, TRANSFORM}

const SPEED = 130
const GRAVITY = 25
const JUMP_HEIGHT = 400
const ENEMEY_DAMAGE = 15
var health = 300
var state = State.IDLE
var player = null
var player_chase = false
const vulnerable = ""
const resistance = "fire"
var can_smash = true
var can_cast_spell = true
var can_attack = true
var attack_damage = 20
var spell_damage = 50
var smash_damage = 30
var phase_one
var phase_two

var anim
@onready var anim1 = $AnimatedSprite2D
@onready var anim2 = $AnimatedSprite2D_slime
@onready var healthbar = $HealthBar
@onready var spell = preload ("res://scenes/BringerOfDeath/Spell.tscn").instantiate()
@onready var attack_audio = $Deamon_Swing
@onready var cast_audio = $Deamon_Swing
@onready var smashCD = $SmashCD
@onready var spellCD = $SpellCD
@onready var attackCD = $AttackCD

func _ready():
	phase_one = true
	phase_two = false
	$AnimatedSprite2D.hide()
	$AnimatedSprite2D_slime.show()
	$Node2D/Area2D/CollisionShape2D.disabled = true
	$Node2D/Area2D/CollisionShape2D2.disabled = true
	$SmashArea/CollisionShape2D.disabled = true
	set_state(State.IDLE)
	healthbar.init_health(health)
	smashCD.connect("timeout", _on_smashcd_timeout)
	spellCD.connect("timeout", _on_spellcd_timeout)
	attackCD.connect("timeout", _on_attackcd_timeout)
	if phase_one:
		anim = anim2
		health = 30

func phase_two_handler():
	anim = anim1
	phase_one = false
	phase_two = true
	health = 1000
	healthbar.health = health
	$AnimatedSprite2D.show()
	$AnimatedSprite2D_slime.hide()
	$DetectionArea2D/CollisionShape2D.disabled = true
	set_state(State.TRANSFORM)

func _physics_process(delta):
	if health <= 0&&phase_two:
		%Player.can_win = true
		return set_state(State.DEAD)
	if phase_one&&health <= 0:
		phase_two_handler()
	if phase_two:
		match state:
			State.IDLE:
				idle_state(delta)
			State.WALK:
				walk_state(delta)
			State.HIT:
				hit_state(delta)
			State.ATTACK:
				attack_state(delta)
			State.CAST:
				cast_state(delta)
			State.SMASH:
				smash_state(delta)
	if phase_one:
		match state:
			State.IDLE:
				idle_state(delta)
			State.WALK:
				walk_state(delta)
			State.HIT:
				hit_state(delta)

func hit_state(_delta):
	if health <= 0:
		set_state(State.DEAD)
	else:
		set_state(State.WALK)

func set_state(new_state):
	if state == new_state:
		return
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
			anim.play("death")
		State.CAST:
			anim.play("cast")
		State.SMASH:
			anim.play("smash")
		State.FIRE_BREATH:
			anim.play("fire_breath")
		State.TRANSFORM:
			anim.play("transform")

func cast_state(_delta):
	if (!spell):
		spell = preload ("res://scenes/BringerOfDeath/Spell.tscn").instantiate()
	spell.position = player.position
	spell.offset = Vector2i(15, -27)
	if (player.position.distance_to(position) < 200) and can_cast_spell:
		if (anim.frame == 0):
			get_parent().add_child(spell)
		set_state(State.CAST)

func _on_spellcd_timeout():
	set_state(State.WALK)
	can_cast_spell = true

func attack_state(_delta):
	if player.position.distance_to(position) < 80:
		if anim.frame == 1:
			$Node2D/Area2D/CollisionShape2D.disabled = true
			$Node2D/Area2D/CollisionShape2D2.disabled = true
		if anim.frame == 9:
			$Node2D/Area2D/CollisionShape2D.disabled = false
			$Node2D/Area2D/CollisionShape2D2.disabled = false
		if anim.frame == 13:
			$Node2D/Area2D/CollisionShape2D.disabled = true
			$Node2D/Area2D/CollisionShape2D2.disabled = true
		can_attack = false
	elif (player.position.distance_to(position) < 200) and can_cast_spell:
		can_cast_spell = false
		set_state(State.CAST)
	elif player.position.distance_to(position) < 100 and can_smash:
		can_smash = false
		set_state(State.SMASH)
	else:
		set_state(State.WALK)

func _on_attackcd_timeout():
	can_attack = true

func walk_state(_delta):
	var direction = (player.position - position).normalized()
	velocity.y += GRAVITY
	velocity.x = direction.x * SPEED

	if player.position.x < position.x:
		anim.flip_h = false
		anim.offset.x = 0
		$Node2D.scale.x = 1
	else:
		anim.flip_h = true
		anim.offset.x = 0
		$Node2D.scale.x = -1

	if phase_two:
		if player.position.distance_to(position) < 80:
			set_state(State.ATTACK)

	move_and_slide()

func idle_state(_delta):
	if not player_chase:
		return set_state(State.IDLE)

	if player.position.distance_to(position) < 80:
		set_state(State.ATTACK)
	else:
		set_state(State.WALK)

func smash_state(_delta):
	if player.position.distance_to(position) < 100:
		if anim.frame == 1:
			$SmashArea/CollisionShape2D.disabled = true
		if anim.frame == 10:
			$SmashArea/CollisionShape2D.disabled = false
		if anim.frame == 16:
			$SmashArea/CollisionShape2D.disabled = true

func _on_smashcd_timeout():
	set_state(State.WALK)
	can_smash = true

func _on_detection_area_2d_body_entered(body):
	player = body
	player_chase = true

func get_health():
	return health

func take_damage(damage):
	if health <= 0:
		if phase_one:
			set_state(State.TRANSFORM)
			healthbar.health = health
			return
		%Player.can_win = true
		return set_state(State.DEAD)
	health -= damage
	healthbar.health = health
	set_state(State.HIT)

func _on_area_2d_body_entered(body):
	if body.name == "TileMap":
		velocity.y = -JUMP_HEIGHT
	if body.name == "Player":
		body.take_damage(attack_damage)

func _on_animated_sprite_2d_animation_finished():
	if anim.animation == "death":
		queue_free()
	if anim.animation == "hit":
		set_state(State.WALK)
	if anim.animation == "attack":
		set_state(State.WALK)
	if anim.animation == "cast":
		spell.queue_free()
		set_state(State.WALK)
		player.take_damage(ENEMEY_DAMAGE)
	if anim.animation == "smash":
		set_state(State.WALK)
	if anim.animation == "transform":
		$DetectionArea2D/CollisionShape2D.disabled = false
		set_state(State.WALK)

func _on_smash_area_body_entered_smash(body):
	if body.name == "Player":
		body.take_damage(smash_damage)
