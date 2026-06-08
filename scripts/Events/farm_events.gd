class SeedPlantedEvent:
	var crop_id: String
	var tile_pos: Vector2i
	var count: int
	func _init(p_crop_id: String, p_tile_pos: Vector2i, p_count: int):
		crop_id = p_crop_id; tile_pos = p_tile_pos; count = p_count

class CropGrownEvent:
	var tile_pos: Vector2i
	var new_stage: int
	var max_stage: int
	func _init(p_pos: Vector2i, p_new: int, p_max: int):
		tile_pos = p_pos; new_stage = p_new; max_stage = p_max

class CropHarvestedEvent:
	var tile_pos: Vector2i
	var item_id: String
	var count: int
	func _init(p_pos: Vector2i, p_id: String, p_count: int):
		tile_pos = p_pos; item_id = p_id; count = p_count

class TileHoedEvent:
	var tile_pos: Vector2i
	func _init(p_pos: Vector2i): tile_pos = p_pos

class TileWateredEvent:
	var tile_pos: Vector2i
	func _init(p_pos: Vector2i): tile_pos = p_pos
