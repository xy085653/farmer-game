class RecipeCraftedEvent:
	var recipe_id: String
	var result_item_id: String
	var count: int
	func _init(p_recipe: String, p_item: String, p_count: int):
		recipe_id = p_recipe; result_item_id = p_item; count = p_count

class BuildingPlacedEvent:
	var building_id: String
	var name: String
	var position: Vector2i
	func _init(p_id: String, p_name: String, p_pos: Vector2i):
		building_id = p_id; name = p_name; position = p_pos
