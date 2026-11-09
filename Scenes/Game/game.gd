extends Node

@onready var world: World = $World
@onready var music: AudioStreamPlayer = $World/BigLevel/AudioStreamPlayer

func _ready() -> void:
	var connection_manager: ConnectionManager = $UI/ConnectionManager
	connection_manager.hosting.connect(_on_connection_started)
	connection_manager.joining.connect(_on_connection_started)

func _on_connection_started() -> void:
	if music.stream == null:
		push_error("Music stream is not assigned.")
		return
	music.play()

func _on_connection_manager_hosting() -> void:
	world.spawn_player(1)

	multiplayer.peer_connected.connect(
		func(pid) -> void:
			world.spawn_player(pid)
	)

@rpc("authority", "call_remote", "reliable")
func return_to_connection_screen() -> void:
	if multiplayer.is_server():
		$UI/ConnectionManager.show()
		return

	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
	get_tree().reload_current_scene()
