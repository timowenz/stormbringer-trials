extends Node

var isRaining : bool


# Called when the node enters the scene tree for the first time.
func _ready():
	isRaining = false
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func changeWeather():
	print("Changing weather")
	if(isRaining):
		%Rain.visible = false
		isRaining = false
	else:
		%Rain.visible = true
		isRaining = true
	$"../Sapling".changeGrowth()
	pass


func _on_weather_button_pressed():
	changeWeather()
	pass # Replace with function body.
