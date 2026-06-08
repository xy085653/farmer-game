extends Control
class_name InventoryUI

@export var grid: GridContainer
@export var title_label: Label

var _registry: ServiceRegistry
var _is_open: bool = false

func _ready() -> void:
	_registry = get_node("/root/ServiceRegistry") as ServiceRegistry
	hide()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_inventory"):
		_is_open = not _is_open
		visible = _is_open
		if _is_open:
			_refresh_inventory()
		get_viewport().set_input_as_handled()

func _refresh_inventory() -> void:
	if grid == null or _registry == null or _registry.inventory_service == null:
		return

	# Clear existing
	for child in grid.get_children():
		child.queue_free()

	var inv: InventoryService = _registry.inventory_service
	for i in range(inv.slot_count):
		var slot: Dictionary = inv.get_slot(i)
		var panel := Panel.new()
		panel.size = Vector2(64, 64)

		if slot.item != null and slot.count > 0:
			var label := Label.new()
			label.text = slot.item.item_name + "\n×" + str(slot.count)
			label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			label.size = panel.size
			panel.add_child(label)

		grid.add_child(panel)
