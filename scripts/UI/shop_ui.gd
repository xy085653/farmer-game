extends Control
class_name ShopUI

@export var item_list: ItemList
@export var title_label: Label
@export var money_label: Label
@export var buy_button: Button
@export var close_button: Button

var _registry: ServiceRegistry
var _current_stock: Array[ItemData] = []

func _ready() -> void:
	_registry = get_node("/root/ServiceRegistry") as ServiceRegistry
	if close_button:
		close_button.pressed.connect(_close_shop)
	if buy_button:
		buy_button.pressed.connect(_on_buy_pressed)
	hide()

func open_shop(shop_name: String, stock: Array[ItemData]) -> void:
	_current_stock = stock
	if title_label:
		title_label.text = shop_name
	visible = true
	_refresh_ui()

func _refresh_ui() -> void:
	if item_list:
		item_list.clear()
		for item in _current_stock:
			if item != null:
				item_list.add_item(item.item_name + "  🪙" + str(item.base_price) + "文")

	if money_label and _registry and _registry.economy_service:
		money_label.text = "持有: 🪙 " + str(_registry.economy_service.money) + "文"

func _on_buy_pressed() -> void:
	if item_list == null:
		return
	var selected: PackedInt32Array = item_list.get_selected_items()
	if selected.size() == 0:
		return
	var idx: int = selected[0]
	if idx < 0 or idx >= _current_stock.size():
		return

	var item: ItemData = _current_stock[idx]
	if _registry and _registry.economy_service:
		_registry.economy_service.buy_item(item, 1)
	_refresh_ui()

func _close_shop() -> void:
	visible = false
