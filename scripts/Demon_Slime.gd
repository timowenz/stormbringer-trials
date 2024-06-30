extends CharacterBody2D


const SPEED = 250

var health = 300


var dead = false
var player_in_area = false
var player

func _ready():
	$Hit_taken.hide()
	$Give_damage.hide()
	dead = false

func _physics_process(delta):
	
	if !dead:
		$DetectionArea/CollisionShape2D.disabled = false
		if player_in_area:
			position += (player.position - position) / SPEED
			$AnimatedSprite2D.play("walk")
		else:
			$AnimatedSprite2D.play("idle")
	if dead:
		$DetectionArea/CollisionShape2D.disabled = true
		

func take_damage(damage):
	health = health - damage
	$AnimatedSprite2D.hide()
	$Hit_taken.show()
	$Hit_taken.play("take_damage")
	await get_tree().create_timer(0.5).timeout
	$Hit_taken.hide()
	$AnimatedSprite2D.show()
	if health <= 0 and !dead :
		death()

func give_damage_to_player_from_deamon():
	pass

func death():
	dead = true
	$AnimatedSprite2D.play("death")
	await get_tree().create_timer(1.4).timeout
	queue_free()

func _on_detection_area_body_entered(body):
	if body.has_method("player"):
		player_in_area = true
		player = body


func _on_detection_area_body_exited(body):
	if body.has_method("player"):
		player_in_area = false


func _on_hitbox_area_entered(area):
	var damage
	if area.has_method("give_damage"):
		damage = 50
		take_damage(damage)
		

func give_damage():
	$AnimatedSprite2D.hide()
	$Give_damage.show()
	$Give_damage.play("hit_player")
	await get_tree().create_timer(1).timeout
	$Give_damage.hide()
	$AnimatedSprite2D.show()

func _on_damage_body_entered(body):
	if body.has_method("player"):
		give_damage()
