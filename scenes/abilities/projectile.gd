class_name Projectile
extends Node2D

@export var speed = 100.0

var direction : float = 0.0
var source : Node
var launched = false

func _ready():
	call_deferred("_validate_setup")


func _physics_process(delta):
	position.x += direction * speed * delta

func launch(p_source : Node, p_direction : float, p_user: Node2D):
	source = p_source
	if p_direction == 0 && p_user.get_node("AnimatedSprite2D").flip_h == true:
		p_direction  = -1
	elif p_direction == 0 && p_user.get_node("AnimatedSprite2D").flip_h == false:
		p_direction = 1
	direction = p_direction
	launched = true

func _validate_setup() -> bool:
	var no_problems = true
	if(launched == false):
		push_warning("Projectile created but launch is not called")
		no_problems = false
	
	return no_problems
