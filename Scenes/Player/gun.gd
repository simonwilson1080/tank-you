extends Marker2D

@export var bullet_scene: PackedScene

# rpc so that bullets sync over network
# call local to run on both clients
# using this to minimize cost vs a MultiplayerSynchronizer
@rpc("call_local")
func shoot() -> void:
	var bullet = bullet_scene.instantiate() as Bullet
	
	# prevents bullets from rotating with mouse
	bullet.top_level = true
	bullet.shooter = get_parent().get_parent()
	bullet.global_transform = global_transform
	
	# move the bullets spawn point further ahead of the barrel
	# this stops the bullet from dragging the tank off with it
	bullet.global_transform = global_transform
	bullet.global_position += bullet.global_transform.x * 10.0
	
	add_child(bullet)
	(get_node("../../Arrow1") as AudioStreamPlayer).play()
	
func _process(_delta: float) -> void:
	# fixes shooting from both host and client
	if !is_multiplayer_authority():
		return
		
	if Input.is_action_just_pressed("shoot"):
		shoot.rpc()
