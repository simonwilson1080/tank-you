extends Node

@onready var world: World = $World
@onready var music: AudioStreamPlayer = $World/Level1/AudioStreamPlayer

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
