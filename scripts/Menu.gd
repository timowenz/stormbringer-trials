class_name Menu

extends Control

@onready var adminnode = $AdminMenu

func _ready():
	$CreditSheet.visible = false

func _process(_delta):
	if (Input.is_action_pressed("jump")):
		get_tree().change_scene_to_file("res://scenes/Game.tscn")
		print("Scene changed to Game.tscn")
	if Input.is_action_just_pressed("toggle_admin"):
		toggle_visibility()

func _on_play_button_pressed():
	get_tree().change_scene_to_file("res://scenes/TestScene.tscn")
	print("Scene changed to TestScene.tscn")

func _on_credits_button_pressed():
	$CreditSheet.visible = true

func _on_close_button_pressed():
	$CreditSheet.visible = false


func _on_reset_pressed():
	GlobalVariables.coins = 0
	GlobalVariables.health = 100
	GlobalVariables.damage = 20
	GlobalVariables.speed = 190
	GlobalVariables.mana = 100
	pass 


func _on_lvl_3_pressed():
	get_tree().change_scene_to_file("res://scenes/Game.tscn")
	pass # Replace with function body.


func _on_lvl_4_pressed():
	get_tree().change_scene_to_file("res://scenes/level_2/LevelTwo.tscn")
	pass # Replace with function body.


func _on_lvl_5_pressed():
	get_tree().change_scene_to_file("res://scenes/Deamon_Level.tscn")
	pass # Replace with function body.

func toggle_visibility():
	adminnode.visible = not adminnode.visible
	$admin.visible = not $admin.visible
