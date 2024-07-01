extends StaticBody2D

@export var sceneName : String


func _on_area_2d_body_entered(body):
	if body.name == "Player" and body.can_win == true:
		body.get_parent().get_node("WonGame").show()
		body.get_parent().get_tree().paused = true
