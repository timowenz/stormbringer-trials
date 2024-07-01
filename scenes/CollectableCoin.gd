extends Area2D

var sound = preload("res://scenes/coin_sound.tscn")
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_body_entered(body):
	if body.name == "Player":
		body._on_coin_body_entered()
		var newsound = sound.instantiate()
		$"..".add_child(newsound)
		queue_free()
