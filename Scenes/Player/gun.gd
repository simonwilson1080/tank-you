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
	bullet.global_transform = global_transform
	add_child(bullet)
	
func _process(_delta: float) -> void:
	# fixes shooting from both host and client
	if !is_multiplayer_authority():
		return
		
	if Input.is_action_just_pressed("shoot"):
		shoot.rpc()
