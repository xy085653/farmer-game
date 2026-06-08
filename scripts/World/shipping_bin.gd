extends StaticBody2D
class_name ShippingBin

var _registry: ServiceRegistry
var _pending_items: Array[Dictionary] = []

func _ready() -> void:
	_registry = get_node("/root/ServiceRegistry") as ServiceRegistry
	var bus = get_node("/root/EventBus") as EventBus
	bus.day_ended.connect(_on_day_ended)

func deposit_item(item_id: String, count: int) -> void:
	var inventory: InventoryService = _registry.inventory_service if _registry else null
	if inventory == null or not inventory.has_item(item_id, count):
		return
	inventory.remove_item_by_id(item_id, count)
	_pending_items.append({ item_id = item_id, count = count })

func _on_day_ended(evt: Dictionary) -> void:
	if _registry == null or _pending_items.is_empty():
		return

	var economy: EconomyService = _registry.economy_service
	if economy == null:
		return

	var total_earned: int = 0
	for item in _pending_items:
		total_earned += item.count * 10  # placeholder: 10 coins per item

	economy.add_money(total_earned, "出货箱结算")
	_pending_items.clear()
	print("出货箱结算: 共 ", total_earned, " 文")
