class_name Player
extends CharacterBody2D

@export var speed: float = 100.0

var rot = 0.0

func _enter_tree() -> void:
	set_multiplayer_authority(int(str(name)))
	
# play explode animation for all peers
@rpc("any_peer", "call_local", "reliable")
func play_explosion() -> void:
	var sender := multiplayer.get_remote_sender_id()
	if sender != 1 and !(multiplayer.is_server() and sender == 0):
		return
	
	# hide the tank and barrel before explosion plays
	$Tank.hide()
	$Canon/Canon.hide()
	$Explosion.show()
	$Explosion.play("explode")

# send player that died to connection screen
func die() -> void:
	if !multiplayer.is_server():
		return

	var victim_peer_id = int(name)
	# play the explosion and wait for it to finish before removing player
	play_explosion.rpc()
	await $Explosion.animation_finished
	queue_free()

	var game = get_tree().current_scene
	if victim_peer_id == multiplayer.get_unique_id():
		game.return_to_connection_screen()
	else:
		game.rpc_id(victim_peer_id, "return_to_connection_screen")

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
	
	velocity = velocity.move_toward(input_vector * speed, 400 * delta)
	if velocity != Vector2.ZERO:
		$Tank.play("move")
	
	
	if velocity != Vector2.ZERO:
		self.rotation = velocity.angle()
	
	
	move_and_slide()
