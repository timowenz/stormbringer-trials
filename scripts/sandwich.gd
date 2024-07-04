extends Area2D

func _on_body_entered(body):
	if body.name == "Player":
		body.health += 40
		body.healthbar.health = body.health
		%SandwichSound.play()
		queue_free()
