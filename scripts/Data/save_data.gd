class SaveData:
	var player_position: Vector2
	var current_map: String = ""
	var game_time: Dictionary = {}
	var inventory_slots: Array[Dictionary] = []
	var money: int = 0
	var farm_tiles: Array[Dictionary] = []
	var buildings: Array[Dictionary] = []

class SavedSlot:
	var item_id: String = ""
	var count: int = 0

class SavedTile:
	var position: Vector2i
	var state: int = 0
	var crop_id: String = ""
	var growth_stage: int = 0
	var growth_progress: float = 0.0

class SavedBuilding:
	var building_id: String = ""
	var position: Vector2i
