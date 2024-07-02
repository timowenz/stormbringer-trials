extends ProgressBar

@onready var timer = $Timer
@onready var mana_spent_bar = $ManaSpentBar

var mana = 0: set = _set_mana

func init_mana(_mana):
	mana = _mana
	max_value = mana
	value = mana
	mana_spent_bar.max_value = mana
	mana_spent_bar.value = mana

func _set_mana(new_mana):
	var prev_mana = mana
	mana = min(max_value, new_mana)
	value = mana
	if mana <= 0:
		mana = 0
		mana_spent_bar.value = mana
		
	if mana < prev_mana:
		timer.start()
	else:
		mana_spent_bar.value = mana

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_timer_timeout():
	mana_spent_bar.value = mana
