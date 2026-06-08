extends Node

static var instance: ServiceRegistry

# Services - set by register_services()
var time_service: Node
var inventory_service: Node
var farm_service: Node
var economy_service: Node
var craft_service: Node
var world_service: Node

var _registered: bool = false

func _enter_tree() -> void:
	instance = self

func register_services() -> void:
	if _registered:
		return

	time_service = preload("res://scripts/Services/time_service.gd").new()
	inventory_service = preload("res://scripts/Services/inventory_service.gd").new()
	farm_service = preload("res://scripts/Services/farm_service.gd").new()
	economy_service = preload("res://scripts/Services/economy_service.gd").new()
	craft_service = preload("res://scripts/Services/craft_service.gd").new()
	world_service = preload("res://scripts/Services/world_service.gd").new()

	_add_service_node(time_service)
	_add_service_node(inventory_service)
	_add_service_node(farm_service)
	_add_service_node(economy_service)
	_add_service_node(craft_service)
	_add_service_node(world_service)

	_registered = true
	print("ServiceRegistry: All services registered")

func _add_service_node(service: Node) -> void:
	add_child(service)

func _exit_tree() -> void:
	instance = null
