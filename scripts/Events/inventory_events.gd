class ItemAddedEvent:
	var item_id: String
	var count: int
	var slot_index: int
	func _init(p_id: String, p_count: int, p_slot: int):
		item_id = p_id; count = p_count; slot_index = p_slot

class ItemRemovedEvent:
	var item_id: String
	var count: int
	var slot_index: int
	func _init(p_id: String, p_count: int, p_slot: int):
		item_id = p_id; count = p_count; slot_index = p_slot

class InventoryChangedEvent:
	func _init(): pass
