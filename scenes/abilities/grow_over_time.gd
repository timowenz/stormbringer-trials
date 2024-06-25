class_name GrowOverTime
extends Node2D
# Scales Node2D over time

signal growing_changed(status : bool)

@export var growth_curve : Curve
@export var duration : float = 1.0

#start growing as soon as the nod eis ready
@export var grow_on_reay = true

var time_elapsed = 0.0
var growing = true : 
	set(value):
		if(value == growing):
			return
		growing = value
		emit_signal("growing_changed", growing)

func _ready():
	if(grow_on_reay):
		start()

func _process(delta):
	time_elapsed += delta
	if(growing):
		grow()
	

func start():
	growing = true

func grow():
	var progress = clampf(time_elapsed / duration, 0.0 , 1.0)
	scale = Vector2(
		growth_curve.sample(progress),
		growth_curve.sample(progress)
	)
	
	if(progress >= 1.0):
		growing = false
