extends Node
class_name FarmService

var _event_bus: EventBus
var _crop_data_by_crop_id: Dictionary = {}  # crop_id -> CropData
var _crop_data_by_seed_id: Dictionary = {}  # seed ItemId -> CropData

func _ready() -> void:
	_event_bus = get_node("/root/EventBus") as EventBus
	_load_crop_data()
	_event_bus.day_ended.connect(_on_day_ended)

func _load_crop_data() -> void:
	_crop_data_by_crop_id.clear()
	_crop_data_by_seed_id.clear()

	var dir: DirAccess = DirAccess.open("res://resources/Crops/")
	if dir == null:
		print("FarmService: Could not open Crops directory")
		return

	dir.list_dir_begin()
	var file_name: String = dir.get_next()
	while file_name != "":
		if file_name.ends_with(".tres") or file_name.ends_with(".res"):
			var path: String = "res://resources/Crops/" + file_name
			var crop_data: CropData = ResourceLoader.load(path) as CropData
			if crop_data != null:
				_crop_data_by_crop_id[crop_data.crop_id] = crop_data
				if crop_data.seed_item != null:
					_crop_data_by_seed_id[crop_data.seed_item.item_id] = crop_data
		file_name = dir.get_next()
	dir.list_dir_end()

	print("FarmService: Loaded ", _crop_data_by_crop_id.size(), " crops")

static func _world_to_tile(world_pos: Vector2) -> Vector2i:
	return Vector2i(floori(world_pos.x / 32), floori(world_pos.y / 32))

func _get_tile_manager() -> Node:
	var farm: Node = get_tree().root.get_node_or_null("Farm")
	if farm:
		return farm.get_node_or_null("FarmTileManager")
	return null

func hoe_tile(world_pos: Vector2) -> bool:
	var tile_pos: Vector2i = _world_to_tile(world_pos)
	var tile_manager = _get_tile_manager()
	if tile_manager == null:
		return false
	if not tile_manager.can_hoe(tile_pos):
		return false
	tile_manager.set_tile_state(tile_pos, FarmTileManager.HoeDirtState.TILLED)
	return true

func plant_seed(world_pos: Vector2, seed_item: ItemData) -> bool:
	if seed_item == null:
		return false
	if not _crop_data_by_seed_id.has(seed_item.item_id):
		return false

	var crop_data: CropData = _crop_data_by_seed_id[seed_item.item_id]
	var tile_pos: Vector2i = _world_to_tile(world_pos)
	var tile_manager = _get_tile_manager()
	if tile_manager == null:
		return false

	# Check season
	var time_service: TimeService = get_node("/root/ServiceRegistry").time_service
	if time_service == null:
		return false
	var current_season: int = time_service.current_time.season
	if crop_data.allowed_seasons.size() > 0 and not current_season in crop_data.allowed_seasons:
		return false

	# Check tile is TilledWet
	if tile_manager.get_state(tile_pos) != FarmTileManager.HoeDirtState.TILLED_WET:
		return false

	# Remove seed from inventory
	var inventory: InventoryService = get_node("/root/ServiceRegistry").inventory_service
	if inventory == null:
		return false
	if not inventory.remove_item_by_id(seed_item.item_id, 1):
		return false

	# Plant
	tile_manager.plant_crop(tile_pos, crop_data.crop_id)
	return true

func water_tile(world_pos: Vector2) -> bool:
	var tile_pos: Vector2i = _world_to_tile(world_pos)
	var tile_manager = _get_tile_manager()
	if tile_manager == null:
		return false
	tile_manager.water_tile(tile_pos)
	return true

func harvest_crop(world_pos: Vector2) -> bool:
	var tile_pos: Vector2i = _world_to_tile(world_pos)
	var tile_manager = _get_tile_manager()
	if tile_manager == null:
		return false

	var tile_data = tile_manager.get_tile_data(tile_pos)
	if tile_data == null:
		return false

	if tile_data.state != FarmTileManager.HoeDirtState.MATURE:
		return false
	if tile_data.crop_id.is_empty():
		return false
	if not _crop_data_by_crop_id.has(tile_data.crop_id):
		return false

	var crop_data: CropData = _crop_data_by_crop_id[tile_data.crop_id]
	var max_stage: int = crop_data.growth_stages - 1
	if tile_data.growth_stage < max_stage:
		return false

	# Add harvest to inventory
	var inventory: InventoryService = get_node("/root/ServiceRegistry").inventory_service
	if inventory == null:
		return false
	inventory.add_item(crop_data.harvest_item, crop_data.harvest_count)

	# Regrow or revert
	if crop_data.can_regrow:
		tile_manager.reset_growth(tile_pos, 0)
	else:
		tile_manager.set_tile_state(tile_pos, FarmTileManager.HoeDirtState.TILLED)

	_event_bus.crop_harvested.emit(tile_pos, crop_data.harvest_item.item_id, crop_data.harvest_count)
	return true

func tick_growth(time_dict: Dictionary) -> void:
	var time_service: TimeService = get_node("/root/ServiceRegistry").time_service
	if time_service == null:
		return

	var effect: Dictionary = time_service.get_current_term_effect()
	var growth: float = 1.0 * effect.growth_multiplier

	var tile_manager = _get_tile_manager()
	if tile_manager:
		tile_manager.advance_growth(growth)

func get_tile_state(world_pos: Vector2) -> int:
	var tile_pos: Vector2i = _world_to_tile(world_pos)
	var tile_manager = _get_tile_manager()
	if tile_manager == null:
		return FarmTileManager.HoeDirtState.NORMAL
	return tile_manager.get_state(tile_pos)

func _on_day_ended(evt: Dictionary) -> void:
	tick_growth(evt)
