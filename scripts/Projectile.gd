extends CharacterBody2D

var player = null
var player_chase = false

func _physics_process(delta):
	
	if (player_chase):
		# move to player position
		var direction = (player.global_position - global_position).normalized()

		velocity = direction * 100

	move_and_slide()

func _on_detection_area_2d_body_entered(body: Node2D):
	if (body.name == "Player"):
		player = body
		player_chase = true

func _on_hit_area_2d_body_entered(body: Node2D):
	if (body.name == "Player"):
		player.take_damage(10)
		queue_free()
	if (body.name == "TileMap"):
		queue_free()
