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
	apply_damage(damage_per_tick)

func apply_damage(p_tick_damage : int):
	var extra_damage = damage_per_tick
	for target in targets_in_area:
		if target.vulnerable == damage_type:
			extra_damage = extra_damage * 2
		if target.resistance == damage_type:
			extra_damage = extra_damage / 2
		target.take_damage(extra_damage)
	

func _on_body_entered(p_body : Node2D):
	if !targets_in_area.has(p_body) && p_body.name != "Player" && p_body.name != "TileMap":
		targets_in_area.append(p_body)

func _on_body_exited(p_body : Node2D):
	if targets_in_area.has(p_body) && p_body.name != "Player" && p_body.name != "TileMap":
		targets_in_area.erase(p_body)
