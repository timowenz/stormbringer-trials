extends Node2D

var inSaplingMode : bool

# Called when the node enters the scene tree for the first time.
func _ready():
	inSaplingMode = true
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func changeGrowth():
	if(inSaplingMode):
		$Sapling.visible = false
		$Tree.visible = true
		$Tree/StaticBody2D/CollisionShape2D.disabled = false
		inSaplingMode = false
	else:
		$Sapling.visible = true
		$Tree.visible = false
		$Tree/StaticBody2D/CollisionShape2D.disabled = true
		inSaplingMode = true
