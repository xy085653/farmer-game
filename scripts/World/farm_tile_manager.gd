extends Node
class_name FarmTileManager

enum HoeDirtState { NORMAL, TILLED, TILLED_WET, PLANTED, MATURE }

var _tiles: Dictionary = {}  # Vector2i -> HoeDirtData
var _ground_layer: TileMapLayer
var _event_bus: EventBus

func _ready() -> void:
	_ground_layer = get_parent().get_node_or_null("GroundLayer") as TileMapLayer
	_event_bus = get_node("/root/EventBus") as EventBus

func is_tilled(tile_pos: Vector2i) -> bool:
	return _tiles.has(tile_pos) and _tiles[tile_pos].state >= HoeDirtState.TILLED

func can_hoe(tile_pos: Vector2i) -> bool:
	return not _tiles.has(tile_pos) or _tiles[tile_pos].state == HoeDirtState.NORMAL

func can_plant(tile_pos: Vector2i) -> bool:
	return _tiles.has(tile_pos) and _tiles[tile_pos].state == HoeDirtState.TILLED_WET

func can_water(tile_pos: Vector2i) -> bool:
	return _tiles.has(tile_pos) and not _tiles[tile_pos].watered

func get_tile_data(tile_pos: Vector2i):
	if _tiles.has(tile_pos):
		return _tiles[tile_pos].duplicate()
	return null

func get_state(tile_pos: Vector2i) -> int:
	if _tiles.has(tile_pos):
		return _tiles[tile_pos].state
	return HoeDirtState.NORMAL

func set_tile_state(tile_pos: Vector2i, state: int) -> void:
	var data: Dictionary
	if _tiles.has(tile_pos):
		data = _tiles[tile_pos]
		data.state = state
		if state == HoeDirtState.NORMAL:
			data.crop_id = ""
			data.growth_stage = 0
			data.growth_progress = 0.0
			data.watered = false
	else:
		data = {
			tile_pos = tile_pos,
			state = state,
			crop_id = "",
			growth_stage = 0,
			growth_progress = 0.0,
			watered = false
		}

	_tiles[tile_pos] = data
	_update_tile_visual(tile_pos)

	if state == HoeDirtState.TILLED:
		_event_bus.tile_hoed.emit(tile_pos)

func plant_crop(tile_pos: Vector2i, crop_id: String) -> void:
	if not _tiles.has(tile_pos):
		return

	var data = _tiles[tile_pos]
	data.state = HoeDirtState.PLANTED
	data.crop_id = crop_id
	data.growth_stage = 0
	data.growth_progress = 0.0
	_tiles[tile_pos] = data

	_update_tile_visual(tile_pos)
	_event_bus.seed_planted.emit(crop_id, tile_pos, 1)

func water_tile(tile_pos: Vector2i) -> void:
	if not _tiles.has(tile_pos):
		return

	var data = _tiles[tile_pos]
	data.watered = true

	if data.state == HoeDirtState.TILLED:
		data.state = HoeDirtState.TILLED_WET

	_tiles[tile_pos] = data
	_update_tile_visual(tile_pos)
	_event_bus.tile_watered.emit(tile_pos)

func reset_growth(tile_pos: Vector2i, stage: int) -> void:
	if not _tiles.has(tile_pos):
		return

	var data = _tiles[tile_pos]
	data.growth_stage = stage
	data.growth_progress = 0.0
	_tiles[tile_pos] = data
	_update_tile_visual(tile_pos)

func advance_growth(growth_amount: float) -> void:
	var keys: Array = _tiles.keys()
	for tile_pos in keys:
		if not _tiles.has(tile_pos):
			continue

		var data = _tiles[tile_pos]

		# Advance growth for planted, watered tiles
		if data.state == HoeDirtState.PLANTED and data.watered:
			data.growth_progress += growth_amount
			var max_stage: int = 5

			while data.growth_progress >= 1.0:
				data.growth_progress -= 1.0
				data.growth_stage += 1

				if data.growth_stage >= max_stage:
					data.growth_stage = max_stage
					data.state = HoeDirtState.MATURE
					data.growth_progress = 0.0
					_event_bus.crop_grown.emit(tile_pos, data.growth_stage, max_stage)
					break

				_event_bus.crop_grown.emit(tile_pos, data.growth_stage, max_stage)

			_update_tile_visual(tile_pos)

		# Reset watered at end of day
		data.watered = false

		# Revert unplanted TilledWet to Tilled
		if data.state == HoeDirtState.TILLED_WET and data.crop_id.is_empty():
			data.state = HoeDirtState.TILLED
			_update_tile_visual(tile_pos)

		_tiles[tile_pos] = data

func _update_tile_visual(tile_pos: Vector2i) -> void:
	if _ground_layer == null:
		return

	if not _tiles.has(tile_pos):
		_ground_layer.set_cell(tile_pos, -1, Vector2i.ZERO, -1)
		return

	var data = _tiles[tile_pos]
	var atlas_coords: int
	match data.state:
		HoeDirtState.NORMAL: atlas_coords = 0
		HoeDirtState.TILLED: atlas_coords = 1
		HoeDirtState.TILLED_WET: atlas_coords = 2
		HoeDirtState.PLANTED: atlas_coords = 3 + data.growth_stage
		HoeDirtState.MATURE: atlas_coords = 3 + data.growth_stage
		_: atlas_coords = 0

	_ground_layer.set_cell(tile_pos, 0, Vector2i(atlas_coords, 0), -1)
