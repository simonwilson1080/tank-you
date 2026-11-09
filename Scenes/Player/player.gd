class_name Player
extends CharacterBody2D

@export var speed: float = 100.0

@onready var minimap_layer: CanvasLayer = $MinimapLayer
@onready var minimap_viewport: SubViewport = $MinimapLayer/SubViewportContainer/SubViewport
@onready var minimap_camera: Camera2D = $MinimapLayer/SubViewportContainer/SubViewport/Camera2D

var rot = 0.0

func _ready() -> void:
	# sets main camera to hide the minimap icon
	# sets the minimap camera to show minimap icon
	get_viewport().canvas_cull_mask = 1
	minimap_viewport.canvas_cull_mask = 3

	$Camera2D.enabled = is_multiplayer_authority()
	
	minimap_layer.visible = false
	
	# makes it so it shows the level and all players
	minimap_layer.visible = is_multiplayer_authority()
	if not is_multiplayer_authority():
		return

	minimap_viewport.world_2d = get_viewport().world_2d

	# calculates center of map from object
	# assigns it as the position for the view for every client.
	# minimap will be the same for every client
	var level := get_tree().current_scene.get_node("World/BigLevel") as TileMapLayer
	var cells := level.get_used_rect()
	if cells.size != Vector2i.ZERO:
		var first := level.map_to_local(cells.position)
		var last := level.map_to_local(cells.end - Vector2i.ONE)
		minimap_camera.global_position = level.to_global((first + last) / 2.0)

func _process(_delta: float) -> void:
	# show minimap when holding down 'space'
	if is_multiplayer_authority():
		minimap_layer.visible = Input.is_action_pressed("ShowMap")

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
	$BombExplode.play()

# send player that died to connection screen
func die() -> void:
	if !multiplayer.is_server():
		return

	var victim_peer_id = int(name)
	# play the explosion and wait for it to finish before removing player
	play_explosion.rpc()
	await $Explosion.animation_finished
	queue_free()

	# send back to connect menu
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
		if not $Move.playing:
			$Move.play()
	
	if velocity != Vector2.ZERO:
		self.rotation = velocity.angle()
	
	
	move_and_slide()
