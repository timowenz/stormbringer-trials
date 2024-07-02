extends Node2D

var playerhealth

@onready var gameOverTimer = $GameOverTimer

@export var nextLevel: String
var can_game_over: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	can_game_over = false
	get_tree().paused = false
	$GameOver.get_node("MainMenu").pressed.connect(main_menu)
	$GameOver.get_node("Restart").pressed.connect(new_game)
	$GameOver.get_node("Quit").pressed.connect(quit)
	$Pause.get_node("Resume").pressed.connect(resume)
	$Pause.get_node("MainMenu").pressed.connect(main_menu)
	$Pause.get_node("Restart").pressed.connect(new_game)
	$Pause.get_node("Quit").pressed.connect(quit)
	$WonGame.get_node("Continue").pressed.connect(next_level)
	$WonGame.get_node("MainMenu").pressed.connect(main_menu)
	$WonGame.get_node("Restart").pressed.connect(new_game)
	$WonGame.get_node("Quit").pressed.connect(quit)
	$GameOver.hide()
	$Pause.hide()
	$WonGame.hide()

func add_boss_killed():
	print("boss killed")
	$Player.bosses_killed += 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if $Player.bosses_killed == 2:
		$Player.can_win = true
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

func next_level():
	get_tree().paused = false
	get_tree().change_scene_to_file(nextLevel)

func main_menu():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/Menu.tscn")

func new_game():
	get_tree().reload_current_scene()

func resume():
	$Pause.hide()
	get_tree().paused = false

func _on_game_over_timer_timeout():
	can_game_over = true


func _on_shop4_pressed(extra_arg_0):
	pass # Replace with function body.
