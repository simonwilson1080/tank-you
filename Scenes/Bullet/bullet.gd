extends CharacterBody2D
class_name Bullet

@export var SPEED: float = 300.0
var shooter: Node2D = null
var bounce_count = 0

func _physics_process(delta: float) -> void:

	var movement = global_transform.x * SPEED * delta
	
	# move_and_collide returns data ONLY if it hits a physics wall
	var collision_info = move_and_collide(movement)
	
	if collision_info:
		bounce_count += 1
		var body = collision_info.get_collider()
		
		if bounce_count >= 4:
			queue_free()
		
		# Ignore the person who shot it
		if body == shooter:
			# If we hit the shooter, manually force the bullet past them so it doesn't get stuck
			global_position += movement
			return
			
		# Handle Player hit.
		# now calls die function so only the player that was hit gets connection screen
		if body is Player:
			if multiplayer.is_server():
				body.die()
			queue_free()
			return
		
		# wall collision sfx
		$Tink.play()
		
		# Retrieve the completely accurate surface normal from the hit point
		var normal: Vector2 = collision_info.get_normal()
		
		# Bounce our current forward vector against the wall normal
		var new_direction: Vector2 = global_transform.x.bounce(normal)
		
		# Rotate the bullet to point in the new direction
		global_rotation = new_direction.angle()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
