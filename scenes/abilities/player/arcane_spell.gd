class_name ArcaneSpellAbility
extends Node

@export var use_ability_action_name = "spell_q"
@export var ability : Ability
@export var user : Node2D
@export var cooldown : Timer
@export var mana_cost: int

var canCastSpell: bool = true;

func _ready():
	cooldown.connect("timeout", _on_timeout)

func _input(event):
	if(event.is_action_pressed(use_ability_action_name) && canCastSpell && user.mana >= mana_cost):
		$"../SFX/SoundArcaneSpell".play()
		ability.use(user)
		user.reduce_mana(mana_cost)
		canCastSpell = false
		cooldown.start()

func _on_timeout():
	canCastSpell = true
