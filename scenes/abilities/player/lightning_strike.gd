extends Node

@export var use_ability_action_name = "spell_w"
@export var ability : Ability
@export var user : Node2D
@export var cooldown : Timer

var canCastSpell: bool = true;

func _ready():
	cooldown.connect("timeout", _on_timeout)

func _input(event):
	if(event.is_action_pressed(use_ability_action_name) && canCastSpell):
		$"../SFX/SoundLightningStrikeSpell".play()
		ability.use(user)
		canCastSpell = false
		cooldown.start()

func _on_timeout():
	canCastSpell = true

