extends Area2D

@export var damage_per_tick = 5
@export var damage_tick_timer : Timer

var targets_in_area : Array[CharacterBody2D]

func _ready():
	damage_tick_timer.connect("timeout", _on_timeout)
	connect("body_entered", _on_body_entered)
	connect("body_exited", _on_body_exited)

func _on_timeout():
	apply_damage(damage_per_tick)

func apply_damage(p_tick_damage : int):
	for target in targets_in_area:
		print("enemy taking damage")
		target.take_damage(30)
	

func _on_body_entered(p_body : Node2D):
	print("enemy entered")
	for child in p_body.get_parent().get_children():
		if child is Enemy && !targets_in_area.has(child):
			targets_in_area.append(child)
	print(targets_in_area)

func _on_body_exited(p_body : Node2D):
	print("enemy exited")
	for child in p_body.get_parent().get_children():
		if child is Enemy && targets_in_area.has(child):
			targets_in_area.erase(child)
