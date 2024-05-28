extends Area2D

@onready var voidTimer = $VoidTimer

func _ready():
	while true:
		voidTimer.start()
		await voidTimer.timeout
		position.x += 10
	

func _on_body_entered(body):
	if body.name == "Player":
		body.take_damage(100)
