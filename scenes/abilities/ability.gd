class_name Ability
extends Resource

## Tries to use ability and returns whether it was successful or not
func use(p_user : Node2D) -> bool:
	push_error("virtual function implement in child class")
	return false
