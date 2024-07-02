extends Area2D

func _on_body_entered(body):
	if body.name == "Player":
		body.health += 10
		body.healthbar.health = body.health
		queue_free()
