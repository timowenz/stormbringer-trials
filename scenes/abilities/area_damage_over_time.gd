extends Area2D

@export var damage_per_tick = 5
@export var damage_tick_timer : Timer
@export var damage_type: String

var targets_in_area : Array[CharacterBody2D]

func _ready():
	damage_tick_timer.connect("timeout", _on_timeout)
	connect("body_entered", _on_body_entered)
	connect("body_exited", _on_body_exited)

func _on_timeout():
	print("timeout")
	apply_damage(damage_per_tick)

func apply_damage(p_tick_damage : int):
	var extra_damage = damage_per_tick
	for target in targets_in_area:
		print("enemy taking damage")
		if target.vulnerable == damage_type:
			extra_damage = damage_per_tick * 2
		target.take_damage(extra_damage)
	

func _on_body_entered(p_body : Node2D):
	print("enemy entered")
	if !targets_in_area.has(p_body) && p_body.name != "Player":
		targets_in_area.append(p_body)
	print(targets_in_area)

func _on_body_exited(p_body : Node2D):
	print("enemy exited")
	if targets_in_area.has(p_body) && p_body.name != "Player":
		targets_in_area.erase(p_body)
