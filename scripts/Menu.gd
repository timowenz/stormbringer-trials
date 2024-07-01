class_name Menu

extends Control

func _ready():
	$CreditSheet.visible = false

func _process(_delta):
	if (Input.is_action_pressed("jump")):
		get_tree().change_scene_to_file("res://scenes/Game.tscn")
		print("Scene changed to Game.tscn")

func _on_play_button_pressed():
	get_tree().change_scene_to_file("res://scenes/Game.tscn")
	print("Scene changed to Game.tscn")

func _on_credits_button_pressed():
	$CreditSheet.visible = true

func _on_close_button_pressed():
	$CreditSheet.visible = false
