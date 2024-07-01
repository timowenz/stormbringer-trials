extends TextureButton

@onready var cooldown = $Cooldown
@export var Spellkey: String
@onready var time = $Time
@export var timer: Timer
@onready var panel = $Panel
@onready var key = $Key



var change_key = "":
	set(value):
		change_key = value
		key.text = Spellkey
		
		shortcut = Shortcut.new()
		var input_key = InputEventKey.new()
		input_key.keycode = value.unicode_at(0)
		
		shortcut.events = [input_key]


func _ready():
	timer.connect("timeout", _on_timeout)
	key.text = Spellkey
	change_key = Spellkey
	cooldown.max_value = timer.wait_time
	set_process(false)

func _process(delta):
	time.text = "%3.1f" % timer.time_left
	cooldown.value = timer.time_left


func _on_pressed():
	timer.start()
	disabled = true
	set_process(true)


func _on_timeout():
	disabled = false
	time.text = ""
	cooldown.value = 0
	set_process(false)
