extends Node
class_name InventoryService

const DEFAULT_SLOT_COUNT: int = 24
const DEFAULT_HOTBAR_SIZE: int = 8

var _slots: Array[Dictionary] = []
var _event_bus: EventBus
var _current_hotbar_index: int = 0

var slot_count: int:
	get: return DEFAULT_SLOT_COUNT

var hotbar_size: int:
	get: return DEFAULT_HOTBAR_SIZE

var current_hotbar_index: int:
	get: return _current_hotbar_index

var current_tool: Dictionary:
	get: return _slots[_current_hotbar_index]

func _ready() -> void:
	_slots.clear()
	for i in range(DEFAULT_SLOT_COUNT):
		_slots.append({ item = null, count = 0 })
	_event_bus = get_node("/root/EventBus") as EventBus
	_current_hotbar_index = 0

func get_slot(index: int) -> Dictionary:
	if index < 0 or index >= DEFAULT_SLOT_COUNT:
		return { item = null, count = 0 }
	return _slots[index]

func add_item(item: ItemData, count: int = 1) -> bool:
	if item == null or count <= 0:
		return false

	var remaining: int = count
	var max_stack: int = item.max_stack

	# Step 1: stack onto existing slots
	for i in range(DEFAULT_SLOT_COUNT):
		if remaining <= 0: break
		var slot = _slots[i]
		if slot.item != null and slot.item.item_id == item.item_id and slot.count < max_stack:
			var space: int = max_stack - slot.count
			var to_add: int = min(remaining, space)
			slot.count += to_add
			remaining -= to_add
			_slots[i] = slot
			_event_bus.item_added.emit(item.item_id, to_add, i)

	# Step 2: fill empty slots
	for i in range(DEFAULT_SLOT_COUNT):
		if remaining <= 0: break
		var slot = _slots[i]
		if slot.item == null or slot.count <= 0:
			var to_add: int = min(remaining, max_stack)
			_slots[i] = { item = item, count = to_add }
			remaining -= to_add
			_event_bus.item_added.emit(item.item_id, to_add, i)

	_event_bus.inventory_changed.emit()
	return remaining == 0

func remove_item(slot_index: int, count: int = 1) -> bool:
	if slot_index < 0 or slot_index >= DEFAULT_SLOT_COUNT or count <= 0:
		return false
	var slot = _slots[slot_index]
	if slot.item == null or slot.count <= 0:
		return false

	var item_id: String = slot.item.item_id
	var to_remove: int = min(count, slot.count)
	slot.count -= to_remove

	if slot.count <= 0:
		slot.item = null
		slot.count = 0

	_slots[slot_index] = slot
	_event_bus.item_removed.emit(item_id, to_remove, slot_index)
	_event_bus.inventory_changed.emit()
	return true

func remove_item_by_id(item_id: String, count: int = 1) -> bool:
	if item_id.is_empty() or count <= 0:
		return false

	var remaining: int = count

	for i in range(DEFAULT_SLOT_COUNT):
		if remaining <= 0: break
		var slot = _slots[i]
		if slot.item != null and slot.item.item_id == item_id:
			var to_remove: int = min(remaining, slot.count)
			slot.count -= to_remove
			remaining -= to_remove
			if slot.count <= 0:
				slot.item = null
			_slots[i] = slot
			_event_bus.item_removed.emit(item_id, to_remove, i)

	var total_removed: int = count - remaining
	if total_removed > 0:
		_event_bus.inventory_changed.emit()
	return remaining == 0

func get_item_count(item_id: String) -> int:
	var total: int = 0
	for i in range(DEFAULT_SLOT_COUNT):
		var slot = _slots[i]
		if slot.item != null and slot.item.item_id == item_id:
			total += slot.count
	return total

func has_item(item_id: String, count: int = 1) -> bool:
	return get_item_count(item_id) >= count

func find_slot_for_item(item_id: String) -> int:
	for i in range(DEFAULT_SLOT_COUNT):
		var slot = _slots[i]
		if slot.item != null and slot.item.item_id == item_id:
			return i
	return -1

func find_empty_slot() -> int:
	for i in range(DEFAULT_SLOT_COUNT):
		var slot = _slots[i]
		if slot.item == null or slot.count <= 0:
			return i
	return -1

func swap_slots(from_index: int, to_index: int) -> void:
	if from_index < 0 or from_index >= DEFAULT_SLOT_COUNT or to_index < 0 or to_index >= DEFAULT_SLOT_COUNT:
		return
	if from_index == to_index:
		return
	var temp = _slots[from_index]
	_slots[from_index] = _slots[to_index]
	_slots[to_index] = temp
	_event_bus.inventory_changed.emit()

func set_hotbar_index(index: int) -> void:
	if index >= 0 and index < DEFAULT_HOTBAR_SIZE:
		_current_hotbar_index = index
