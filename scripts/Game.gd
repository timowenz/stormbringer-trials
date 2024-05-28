extends Node2D

var playerhealth

@onready var gameOverTimer = $GameOverTimer

# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().paused = false
	$GameOver.get_node("MainMenu").pressed.connect(main_menu)
	$GameOver.get_node("Restart").pressed.connect(new_game)
	$GameOver.get_node("Quit").pressed.connect(quit)
	$Pause.get_node("Resume").pressed.connect(resume)
	$Pause.get_node("MainMenu").pressed.connect(main_menu)
	$Pause.get_node("Restart").pressed.connect(new_game)
	$Pause.get_node("Quit").pressed.connect(quit)
	$GameOver.hide()
	$Pause.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	playerhealth = $Player.health
	if playerhealth <= 0:
		#gameOverTimer.start()
		#await gameOverTimer.timeout
		$GameOver.show()
		get_tree().paused = true
	if Input.is_action_just_pressed("pause"):
		$Pause.show()
		get_tree().paused = true

func quit():
	get_tree().quit()

func main_menu():
	get_tree().change_scene_to_file("res://scenes/Main.tscn")

func new_game():
	get_tree().change_scene_to_file("res://scenes/Game.tscn")

func resume():
	$Pause.hide()
	get_tree().paused = false
