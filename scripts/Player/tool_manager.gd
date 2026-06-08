extends Node
class_name ToolManager

var _player: PlayerController
var _event_bus: EventBus

func _init(player: PlayerController):
	_player = player
	_event_bus = player.get_node("/root/EventBus") as EventBus

func use_equipped_tool(direction: Vector2) -> void:
	var registry = _player.get_node("/root/ServiceRegistry") as ServiceRegistry
	if not registry or not registry.inventory_service:
		return

	var current_tool: Dictionary = registry.inventory_service.current_tool
	if current_tool.is_empty() or current_tool.item == null:
		return
	if current_tool.item.type != ItemData.ItemType.TOOL:
		return

	var target_pos: Vector2 = _player.global_position + direction * 32

	match current_tool.item.tool_sub_type:
		ItemData.ToolType.HOE:
			if registry.farm_service:
				registry.farm_service.hoe_tile(target_pos)
		ItemData.ToolType.WATERING_CAN:
			if registry.farm_service:
				registry.farm_service.water_tile(target_pos)
