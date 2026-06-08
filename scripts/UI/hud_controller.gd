extends Control
class_name HUDController

@export var time_label: Label
@export var season_label: Label
@export var term_label: Label
@export var money_label: Label
@export var hotbar_container: Control

var _registry: ServiceRegistry

func _ready() -> void:
	_registry = get_node("/root/ServiceRegistry") as ServiceRegistry
	var bus = get_node("/root/EventBus") as EventBus

	bus.phase_changed.connect(func(_old, _new): _update_hud())
	bus.solar_term_changed.connect(func(_old, _new, _eff): _update_hud())
	bus.season_changed.connect(func(_old, _new): _update_hud())
	bus.money_changed.connect(func(_old, _new, _reason): _update_hud())
	bus.inventory_changed.connect(_update_hotbar)

	_update_hud()

func _update_hud() -> void:
	if _registry == null or _registry.time_service == null:
		return
	var time: Dictionary = _registry.time_service.current_time

	if time_label:
		time_label.text = GameTimeResource.get_phase_name(time.phase)
	if season_label:
		season_label.text = GameTimeResource.get_season_name(time.season) + " 第" + str(time.year) + "年"
	if term_label:
		term_label.text = GameTimeResource.get_display_name(time.term) + " 第" + str(time.day_in_term) + "日"
	if money_label and _registry.economy_service:
		money_label.text = "🪙 " + str(_registry.economy_service.money) + "文"

func _update_hotbar() -> void:
	if hotbar_container == null or _registry == null or _registry.inventory_service == null:
		return

	# Clear existing
	for child in hotbar_container.get_children():
		child.queue_free()

	var inv: InventoryService = _registry.inventory_service
	for i in range(inv.hotbar_size):
		var slot: Dictionary = inv.get_slot(i)
		var panel := Panel.new()
		panel.size = Vector2(40, 40)
		panel.mouse_filter = Control.MOUSE_FILTER_IGNORE

		if slot.item != null and slot.count > 0:
			var label := Label.new()
			label.text = slot.item.item_name + "\n×" + str(slot.count)
			label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			label.size = panel.size
			panel.add_child(label)

		# Highlight selected
		if i == inv.current_hotbar_index:
			panel.modulate = Color(1, 1, 0.8)

		hotbar_container.add_child(panel)
