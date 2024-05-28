extends CharacterBody2D

#var state_machine
const SPEED = 190.0
const JUMP_VELOCITY = -300.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# Animation variables
@onready var anim = get_node("AnimationPlayer")
@onready var anim_tree: AnimationTree = $AnimationTree
@onready var healthbar = $CanvasLayer/HealthBar
@onready var effects = $Effects
@onready var hurtTimer = $HurtTimer

var is_attacking: bool = false;
var is_crouching: bool = false;
var can_jump: bool = true
var health
var damage
var jump_count = 0
var max_jumps = 2
const wall_slide_acceleration = 10
const max_slide_speed = 120
var enemy = null
var is_damaged = false
var has_died = false

func _ready():
	effects.play("RESET")
	health = 100
	damage = 50
	can_jump = true
	is_crouching = false
	anim_tree.active = true
	#state_machine = $AnimationTree.get("parameters/playback")
	healthbar.init_health(health)
	$Node2D/AttackArea/AttackColRight.disabled = true

func _process(delta):
	update_anim_params()

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	if is_on_floor():
		can_jump = true
		jump_count = 0

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and jump_count < max_jumps and can_jump:
		velocity.y = JUMP_VELOCITY
		jump_count += 1

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction == - 1 and is_attacking == false:
		get_node("AnimatedSprite2D").flip_h = true
		$Node2D.scale = Vector2( - 1, 1)
	elif direction == 1 and is_attacking == false:
		get_node("AnimatedSprite2D").flip_h = false
		$Node2D.scale = Vector2(1, 1)
	if direction:
		if is_crouching and is_attacking == false:
			velocity.x = direction * SPEED / 1.5
		else:
			if is_attacking == false:
				velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	move_and_slide()
	#handle death
	
	# Handle falling animation
	if not is_on_floor() and velocity.y > 0:
		anim.play("fall")
	elif not is_on_floor() and velocity.y < 0 and can_jump:
		anim.play("jump")

func _set_health(value):
	health = value
	if health <= 0:
		has_died = true
		die()
	healthbar.health = health

func take_damage(value):
	is_damaged = true
	health -= value
	effects.play("hurtBlink")
	hurtTimer.start()
	await hurtTimer.timeout
	effects.play("RESET")
	if health <= 0:
		has_died = true
		die()
	else:
		healthbar.health = health

func _heal(value):
	if health + value > 100:
		health = 100
	health = health + value

func _set_damage(value):
	damage = value

func _increase_damage(value):
	damage = damage + value

func die():
	if has_died:
		$AnimatedSprite2D.play("death")
		if health <= 0:
			print("dead")
	has_died = false

func update_anim_params():
	if health <= 0:
		die()
	else:
		if velocity == Vector2.ZERO:
			idle()
			if Input.is_action_just_pressed("stand_up"):
				stand_up()
				can_jump = true
			if Input.is_action_just_pressed("crouch")||is_crouching:
				crouch()
				can_jump = false
		else:
			if is_crouching and is_attacking == false:
				crouch_walk()
			else:
				if is_attacking == false:
					run()
	
	if Input.is_action_just_pressed("attack"):
		if is_crouching:
			anim_tree["parameters/conditions/crouch_attack"] = true
			$Node2D/AttackArea/AttackColRight.disabled = false
			is_attacking = true
		else:
			anim_tree["parameters/conditions/attack"] = true
			$Node2D/AttackArea/AttackColRight.disabled = false
			is_attacking = true
	else:
		anim_tree["parameters/conditions/attack"] = false
		anim_tree["parameters/conditions/crouch_attack"] = false
		is_attacking = false
	
	if Input.is_action_just_pressed("attack2"):
		anim_tree["parameters/conditions/attack2"] = true
		$Node2D/AttackArea/AttackColRight.disabled = false
		is_attacking = true
	else:
		anim_tree["parameters/conditions/attack2"] = false
		is_attacking = false

func stand_up():
	is_crouching = false
	anim_tree["parameters/conditions/idle"] = true
	anim_tree["parameters/conditions/is_moving"] = false
	anim_tree["parameters/conditions/is_crouch_walking"] = false
	anim_tree["parameters/conditions/crouch"] = false

func crouch():
	is_crouching = true
	anim_tree["parameters/conditions/idle"] = false
	anim_tree["parameters/conditions/is_moving"] = false
	anim_tree["parameters/conditions/is_crouch_walking"] = false
	anim_tree["parameters/conditions/crouch"] = true

func crouch_walk():
	anim_tree["parameters/conditions/idle"] = false
	anim_tree["parameters/conditions/is_moving"] = false
	anim_tree["parameters/conditions/is_crouch_walking"] = true
	anim_tree["parameters/conditions/crouch"] = false

func idle():
	anim_tree["parameters/conditions/idle"] = true
	anim_tree["parameters/conditions/is_moving"] = false
	anim_tree["parameters/conditions/is_crouch_walking"] = false
	anim_tree["parameters/conditions/crouch"] = false

func run():
	anim_tree["parameters/conditions/idle"] = false
	anim_tree["parameters/conditions/is_moving"] = true
	anim_tree["parameters/conditions/is_crouch_walking"] = false
	anim_tree["parameters/conditions/crouch"] = false

func _on_attack_area_body_entered(body):
	print(body)
	if body.name != "TileMap":
		print("damage taken")
		body.take_damage(damage)

func hit():
	if is_damaged:
		anim_tree["parameters/conditions/hit"] = true
		anim_tree["parameters/conditions/idle"] = false
	else:
		anim_tree["parameters/conditions/hit"] = false
		anim_tree["parameters/conditions/idle"] = true

func _on_animation_tree_animation_finished(anim_name):
	if anim_name == "attack" or anim_name == "attack2" or anim_name == "crouchAttack":
		$Node2D/AttackArea/AttackColRight.disabled = true
	if anim_name == "hit":
		anim_tree["parameters/conditions/idle"] = true
		is_damaged = false
