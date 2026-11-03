class_name Player
extends CharacterBody2D

@export var speed: float = 250.0

func _enter_tree() -> void:
	set_multiplayer_authority(int(str(name)))

func _physics_process(delta: float) -> void:
	# restricting host from controlling joined players
	if !is_multiplayer_authority():
		return
	
	# movement
	var dir = Input.get_vector("left", "right", "up", "down")
	velocity = dir * speed
	
	move_and_slide()
