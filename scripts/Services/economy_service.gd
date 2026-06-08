extends Node
class_name EconomyService

var _event_bus: EventBus
var _money: int = 500

var money: int:
	get: return _money

func _ready() -> void:
	_event_bus = get_node("/root/EventBus") as EventBus

func add_money(amount: int, reason: String = "") -> bool:
	if amount <= 0:
		return false
	var old_amount: int = _money
	_money += amount
	_event_bus.money_changed.emit(old_amount, _money, reason)
	return true

func spend_money(amount: int, reason: String = "") -> bool:
	if amount <= 0:
		return false
	if _money < amount:
		return false
	var old_amount: int = _money
	_money -= amount
	_event_bus.money_changed.emit(old_amount, _money, reason)
	return true

func get_sell_price(item: ItemData) -> int:
	if item == null:
		return 0
	var registry: Node = get_node("/root/ServiceRegistry")
	var time_service: TimeService = registry.time_service
	var multiplier: float = 1.0
	if time_service:
		multiplier = time_service.get_current_term_effect().price_multiplier
	return roundi(item.base_price * multiplier)

func buy_item(item: ItemData, count: int = 1) -> bool:
	if item == null or count <= 0:
		return false
	var total_cost: int = item.base_price * count
	var reason: String = "购买 " + item.item_name + " x" + str(count)

	if not spend_money(total_cost, reason):
		return false

	var registry: Node = get_node("/root/ServiceRegistry")
	var inventory: InventoryService = registry.inventory_service
	if inventory == null:
		return false

	var result: bool = inventory.add_item(item, count)
	if not result:
		add_money(total_cost, "退款: 背包已满")
		return false
	return true

func sell_item(item: ItemData, count: int = 1) -> bool:
	if item == null or count <= 0:
		return false
	var registry: Node = get_node("/root/ServiceRegistry")
	var inventory: InventoryService = registry.inventory_service
	if inventory == null:
		return false

	if not inventory.has_item(item.item_id, count):
		return false

	inventory.remove_item_by_id(item.item_id, count)
	var price: int = get_sell_price(item) * count
	add_money(price, "出售 " + item.item_name + " x" + str(count))
	_event_bus.item_sold.emit(item.item_id, count, price)
	return true
