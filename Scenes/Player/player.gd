class_name Player
extends CharacterBody2D

@export var speed: float = 250.0

var rot = 0.0

func _enter_tree() -> void:
	set_multiplayer_authority(int(str(name)))

func _physics_process(delta: float) -> void:
	# restricting host from controlling joined players
	if !is_multiplayer_authority():
		return
	#
	## movement
	#var dir = Input.get_vector("left", "right", "up", "down")
	#velocity = dir * speed
	#
	## rotate when moving tank. NOT WORKING
	#rotation = lerp_angle(rotation, atan2(-velocity.x, -velocity.y), delta*5.0)
	
	# NEW MOVEMENT LOGIC FOR ROTATIONS
	var input_vector = Vector2.ZERO
	input_vector.rotated(rot)
		
	input_vector.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	input_vector.y = Input.get_action_strength("down") - Input.get_action_strength("up")
	input_vector = input_vector.normalized()
	
	velocity = input_vector * speed
		
	if velocity != Vector2.ZERO:
		self.rotation = velocity.angle()
	
	
	move_and_slide()
