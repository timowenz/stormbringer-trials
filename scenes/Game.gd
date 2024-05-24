extends Node2D


@onready var healthbar = $CanvasLayer/HealthBar

# Called when the node enters the scene tree for the first time.
func _ready():
	var health = $Player.health
	healthbar.init_health(health)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
