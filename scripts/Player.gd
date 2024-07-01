extends CharacterBody2D

#var state_machine
var SPEED = 190
const JUMP_VELOCITY = -450.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
#var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var gravity = 1000
var fall_gravity := 1500
var direction: float = 0
var direction2: Vector2 = Vector2.ZERO
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
var max_jumps = 1
const wall_slide_acceleration = 10
const max_slide_speed = 120
var enemy = null
var is_damaged = false
var has_died = false
var bosses_killed = 0
var can_win = false
const dashSpeed = 400
const dashLength = 0.2
var dashing = false
var canDash = true
var coins = 0
var can_attack = true
const acc = 30
const friction = 50
var last_direction: float = 0

func _ready():
	effects.play("RESET")
	health = 100
	damage = 20
	can_jump = true
	is_crouching = false
	anim_tree.active = true
	#state_machine = $AnimationTree.get("parameters/playback")
	healthbar.init_health(health)
	$Node2D/AttackArea/AttackCol.disabled = true
	$Node2D/AttackArea/AttackCol2.disabled = true

func _process(delta):
	if ($CanvasLayer3/Label):
		$CanvasLayer3/Label.text = str(GlobalVariables.coins)
	update_anim_params()

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += get_gravity(velocity) * delta
	
	if is_on_floor():
		can_jump = true
		jump_count = 0
	
	if Input.is_action_just_pressed("dash") and canDash:
		dashing = true
		canDash = false
		anim.play("dash")
		$DashTimer.start()
		$CanDashTimer.start()
	
	if Input.is_action_just_released("ui_accept") and velocity.y < 0:
		velocity.y = JUMP_VELOCITY / 3

	# Handle jump.
	if Input.is_action_just_pressed("jump") and jump_count < max_jumps and can_jump:
		velocity.y = JUMP_VELOCITY
		jump_count += 1
		$SFX/SoundJump.play()

	#if not is_on_floor() and velocity.y > 0:
		#anim.play("fall")
	#elif not is_on_floor() and velocity.y < 0 and can_jump:
		#anim.play("jump")
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	direction = Input.get_axis("ui_left", "ui_right")
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
				if dashing:
					velocity.x = direction * dashSpeed
				else:
					velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	##direction2 = $Node2D.scale
	
	move_and_slide()

func _set_health(value):
	health = value
	if health <= 0:
		has_died = true
		die()
	healthbar.health = health

func take_damage(value):
	$SFX/SoundHit.play()
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
		$SFX/SoundDie.play()
		$AnimatedSprite2D.play("death")
		if health <= 0:
			print("dead")
	has_died = false

func update_anim_params():
	var input_dir: Vector2 = input_direction()
	#handle_fall_jump()
	if health <= 0:
		die()
	else:
		if velocity == Vector2.ZERO:
			if not is_on_floor() and velocity.y > 0:
				falling()
			elif not is_on_floor() and velocity.y < 0 and can_jump:
				jump()
			else:
				add_friction()
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
					if not is_on_floor() and velocity.y > 0:
						falling()
					elif not is_on_floor() and velocity.y < 0 and can_jump:
						jump()
					else:
						accelerate(input_dir)
						run()
						if $SFX/WalkTimer.time_left <= 0:
							##$SFX/SoundWalk.pitch_scale = randf_range(0.8, 1.2)
							$SFX/SoundWalk.play()
							$SFX/WalkTimer.start(0.4)
	
	if Input.is_action_just_pressed("attack") and can_attack:
		if is_crouching:
			anim_tree["parameters/conditions/crouch_attack"] = true
			$Node2D/AttackArea/AttackCol2.disabled = false
			can_attack = false
			is_attacking = true
			if is_attacking:
				$SFX/SoundAttack.play()
			$AttackTimer.start()
			await $AttackTimer.timeout
		else:
			anim_tree["parameters/conditions/attack"] = true
			$Node2D/AttackArea/AttackCol2.disabled = false
			can_attack = false
			is_attacking = true
			if is_attacking:
				$SFX/SoundAttack.play()
			$AttackTimer.start()
			await $AttackTimer.timeout
			
	else:
		anim_tree["parameters/conditions/attack"] = false
		anim_tree["parameters/conditions/crouch_attack"] = false
		is_attacking = false
	
	if Input.is_action_just_pressed("attack2") and can_attack:
		anim_tree["parameters/conditions/attack2"] = true
		$Node2D/AttackArea/AttackCol.disabled = false
		can_attack = false
		is_attacking = true
		if is_attacking:
				$SFX/SoundAttack.play()
		$AttackTimer.start()
		await $AttackTimer.timeout
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

func falling():
	anim_tree["parameters/conditions/idle"] = false
	anim_tree["parameters/conditions/is_moving"] = false
	anim_tree["parameters/conditions/is_crouch_walking"] = false
	anim_tree["parameters/conditions/crouch"] = false
	anim_tree["parameters/conditions/falling"] = true
	anim_tree["parameters/conditions/jump"] = false

func jump():
	anim_tree["parameters/conditions/idle"] = false
	anim_tree["parameters/conditions/is_moving"] = false
	anim_tree["parameters/conditions/is_crouch_walking"] = false
	anim_tree["parameters/conditions/crouch"] = false
	anim_tree["parameters/conditions/falling"] = false
	anim_tree["parameters/conditions/jump"] = true

func handle_fall_jump():
	# Handle falling animation
	if not is_on_floor() and velocity.y > 0:
		falling()
	elif not is_on_floor() and velocity.y < 0 and can_jump:
		jump()

func _on_attack_area_body_entered(body):
	print(body)
	if body.name == "EndGame":
		return
	if body.name != "TileMap":
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
		$Node2D/AttackArea/AttackCol.disabled = true
		$Node2D/AttackArea/AttackCol2.disabled = true
	if anim_name == "hit":
		anim_tree["parameters/conditions/idle"] = true
		is_damaged = false

func _on_dash_timer_timeout() -> void:
	dashing = false

func _on_can_dash_timer_timeout() -> void:
	canDash = true

func _on_coin_body_entered():
	print("Coin collected")
	GlobalVariables.coins += 1
	pass

func _on_trader_body_entered(body):
	if (body.name == "Player"):
		%Shop.visible = true
	pass # Replace with function body.

func _on_trader_body_exited(body):
	if (body.name == "Player"):
		%Shop.visible = false
	pass # Replace with function body.

func _on_shop1_pressed(extra_arg_0):
	if (GlobalVariables.coins >= extra_arg_0):
		GlobalVariables.coins = GlobalVariables.coins - extra_arg_0
		damage = damage * 1.2
		$BuySound.play()
	pass # Replace with function body.

func _on_shop2_pressed(extra_arg_0):
	if (GlobalVariables.coins >= extra_arg_0):
		GlobalVariables.coins = GlobalVariables.coins - extra_arg_0
		health = health * 1.2
	pass # Replace with function body.

func _on_button_3_pressed(extra_arg_0):
	if (GlobalVariables.coins >= extra_arg_0):
		GlobalVariables.coins = GlobalVariables.coins - extra_arg_0
		health = health * 1.4
	pass # Replace with function body.

func _on_shop4_pressed(extra_arg_0):
	if (GlobalVariables.coins >= extra_arg_0):
		GlobalVariables.coins = GlobalVariables.coins - extra_arg_0
		SPEED = SPEED * 1.2
	pass # Replace with function body.

func _on_attack_timer_timeout():
	can_attack = true

func get_gravity(velocity: Vector2):
	if velocity.y < 0:
		return gravity
	return fall_gravity

func input_direction() -> Vector2:
	var input_dir = Vector2.ZERO
	input_dir.x = Input.get_axis("ui_left", "ui_right")
	input_dir = input_dir.normalized()
	return input_dir

func accelerate(direction):
	velocity = velocity.move_toward(SPEED * direction, acc)

func add_friction():
	velocity = velocity.move_toward(Vector2.ZERO, friction)