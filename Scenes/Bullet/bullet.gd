class_name Bullet
extends Area2D

const SPEED: float = 500.0

var shooter: Node2D

func _physics_process(delta: float) -> void:
	global_position += global_transform.x * SPEED * delta
	

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	# despawn bullet when it leaves the screen
	queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body == shooter:
		return

	if body.is_in_group("player"):
		body.queue_free()
		get_tree().change_scene_to_file("res://Scenes/Game/Game.tscn")
