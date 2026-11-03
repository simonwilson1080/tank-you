extends Node2D


func _ready() -> void:
	pass

@rpc("call_local")
func _process(_delta: float) -> void:
	# fixes bullet syncing between clients
	if !is_multiplayer_authority():
		return
		
	# make the cannon look at the mouse
	var mouse_pos = get_global_mouse_position()
	look_at(mouse_pos)
