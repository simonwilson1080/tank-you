extends Node2D

	
func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	# make the cannon look at the mouse
	var mouse_pos = get_global_mouse_position()
	look_at(mouse_pos)
