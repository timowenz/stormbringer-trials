class_name Menu

extends Control

func _ready():
	$CreditSheet.visible = false

func _on_play_button_pressed():
	get_tree().change_scene_to_file("res://scenes/TestScene.tscn")
	print("Scene changed to TestScene.tscn")

func _on_credits_button_pressed():
	$CreditSheet.visible = true

func _on_close_button_pressed():
	$CreditSheet.visible = false


func _on_reset_pressed():
	GlobalVariables.coins = 0
	pass 
