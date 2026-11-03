class_name Bullet
extends Area2D

const SPEED: float = 500.0

func _physics_process(delta: float) -> void:
	global_position += global_transform.x * SPEED * delta
	

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	# despawn bullet when it leaves the screen
	queue_free()
