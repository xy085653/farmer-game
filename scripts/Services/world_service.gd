extends Node
class_name WorldService

var _map_scenes: Dictionary = {}  # name -> PackedScene
var _current_map_instance: Node
var _current_map_name: String = ""

var current_map: String:
	get: return _current_map_name

func _ready() -> void:
	_map_scenes["farm"] = preload("res://scenes/World/Farm.tscn")
	_map_scenes["town"] = preload("res://scenes/World/Town.tscn")
	_map_scenes["forest"] = preload("res://scenes/World/Forest.tscn")
	print("WorldService: Map scenes loaded")

func switch_map(map_name: String) -> void:
	var key: String = map_name.to_lower()

	if not _map_scenes.has(key):
		print("WorldService: Map '%s' not found" % map_name)
		return

	# Remove old map
	if _current_map_instance != null:
		get_tree().root.remove_child(_current_map_instance)
		_current_map_instance.queue_free()
		_current_map_instance = null

	# Instantiate new map
	_current_map_instance = _map_scenes[key].instantiate()
	get_tree().root.add_child(_current_map_instance)
	_current_map_name = key
	print("WorldService: Switched to map '%s'" % key)

func get_player_spawn_position(map_name: String) -> Vector2:
	match map_name.to_lower():
		"farm": return Vector2(400, 300)
		"town": return Vector2(200, 500)
		"forest": return Vector2(100, 100)
		_: return Vector2.ZERO
