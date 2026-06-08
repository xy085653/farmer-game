extends CharacterBody2D
class_name PlayerController

@export var speed: float = 120.0

var _sprite: AnimatedSprite2D
var _facing_direction: Vector2 = Vector2.DOWN
var _event_bus: EventBus
var _tool_manager: Node

func _ready() -> void:
	_sprite = $AnimatedSprite2D as AnimatedSprite2D
	_event_bus = get_node("/root/EventBus") as EventBus
	_tool_manager = ToolManager.new(self)

func _physics_process(delta: float) -> void:
	_handle_movement()
	_handle_interaction()

func _handle_movement() -> void:
	var input_dir: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input_dir * speed

	if input_dir != Vector2.ZERO:
		_facing_direction = input_dir

	move_and_slide()

func _handle_interaction() -> void:
	if Input.is_action_just_pressed("use_tool"):
		_tool_manager.use_equipped_tool(_facing_direction)

	if Input.is_action_just_pressed("interact"):
		_try_interact()

	# Hotbar selection (keys 1-8)
	for i in range(8):
		if Input.is_action_just_pressed("hotbar_" + str(i + 1)):
			var registry = get_node("/root/ServiceRegistry") as ServiceRegistry
			if registry and registry.inventory_service:
				registry.inventory_service.set_hotbar_index(i)

func _try_interact() -> void:
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(global_position, global_position + _facing_direction * 32)
	query.collision_mask = 2  # interactable layer
	var result = space_state.intersect_ray(query)
	if result and result.has("collider"):
		var node = result["collider"] as Node
		if node and node.has_method("interact"):
			node.interact()
