extends Node

# ---- Time Events ----
signal solar_term_changed(old_term: int, new_term: int, effect: Dictionary)
signal phase_changed(old_phase: int, new_phase: int)
signal season_changed(old_season: int, new_season: int)
signal day_started(time: Dictionary)
signal day_ended(time: Dictionary)

# ---- Farm Events ----
signal seed_planted(crop_id: String, tile_pos: Vector2i, count: int)
signal crop_grown(tile_pos: Vector2i, new_stage: int, max_stage: int)
signal crop_harvested(tile_pos: Vector2i, item_id: String, count: int)
signal tile_hoed(tile_pos: Vector2i)
signal tile_watered(tile_pos: Vector2i)

# ---- Inventory Events ----
signal item_added(item_id: String, count: int, slot_index: int)
signal item_removed(item_id: String, count: int, slot_index: int)
signal inventory_changed()

# ---- Economy Events ----
signal money_changed(old_amount: int, new_amount: int, reason: String)
signal item_sold(item_id: String, count: int, total_price: int)

# ---- Craft Events ----
signal recipe_crafted(recipe_id: String, result_item_id: String, count: int)
signal building_placed(building_id: String, name: String, position: Vector2i)

func _ready() -> void:
	pass
