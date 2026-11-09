class_name World
extends Node2D

@export var player_scene: PackedScene
@export var player_spawner: MultiplayerSpawner
@onready var spawn_points: Array[Node] = $SpawnPoints.get_children()

var _next_spawn := 0
var _spawn_index_by_peer: Dictionary


func _ready() -> void:
	# player_spawner
	player_spawner.spawn_function = _ms_player

func spawn_player(authority_pid: int) -> void:
	var spawn_index: int
	
	# save spawn points of each connected player
	if _spawn_index_by_peer.has(authority_pid):
		spawn_index = _spawn_index_by_peer[authority_pid]
	else:
		spawn_index = _next_spawn % spawn_points.size()
		_next_spawn += 1
		_spawn_index_by_peer[authority_pid] = spawn_index
		
	player_spawner.spawn({
		"pid": authority_pid,
		"pos": spawn_points[spawn_index].global_position
	})
	
	## OLD LOGIC
	#var index := _next_spawn % spawn_points.size()
	#_next_spawn += 1
	#
	#player_spawner.spawn({
		#"pid" : authority_pid, 
		#"pos": spawn_points[index].global_position})

func _ms_player(data: Dictionary) -> Player:
	var player = player_scene.instantiate()
	player.name = str(data["pid"])
	player.position = data["pos"]
	
	
	return player
