class MoneyChangedEvent:
	var old_amount: int
	var new_amount: int
	var reason: String
	func _init(p_old: int, p_new: int, p_reason: String):
		old_amount = p_old; new_amount = p_new; reason = p_reason

class ItemSoldEvent:
	var item_id: String
	var count: int
	var total_price: int
	func _init(p_id: String, p_count: int, p_price: int):
		item_id = p_id; count = p_count; total_price = p_price
