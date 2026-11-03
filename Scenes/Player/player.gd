class_name Player
extends CharacterBody2D

@export var speed: float = 250.0

func _physics_process(delta: float) -> void:
	# movement
	var dir = Input.get_vector("left", "right", "up", "down")
	velocity = dir * speed
	
	move_and_slide()
