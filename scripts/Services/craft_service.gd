extends Node
class_name CraftService

var _event_bus: EventBus
var _recipes: Array[RecipeData] = []

func _ready() -> void:
	_event_bus = get_node("/root/EventBus") as EventBus
	_load_recipes()

func _load_recipes() -> void:
	var dir: DirAccess = DirAccess.open("res://resources/Recipes")
	if dir == null:
		return
	dir.list_dir_begin()
	var file_name: String = dir.get_next()
	while file_name != "":
		if file_name.ends_with(".tres") or file_name.ends_with(".res"):
			var recipe: RecipeData = ResourceLoader.load("res://resources/Recipes/" + file_name) as RecipeData
			if recipe != null:
				_recipes.append(recipe)
		file_name = dir.get_next()
	dir.list_dir_end()

func get_available_recipes(bench: int) -> Array[RecipeData]:
	var result: Array[RecipeData] = []
	for r in _recipes:
		if r.workbench == bench:
			result.append(r)
	return result

func can_craft(recipe: RecipeData) -> bool:
	var registry: Node = get_node("/root/ServiceRegistry")
	var inv: InventoryService = registry.inventory_service if registry else null
	if inv == null:
		return false

	for ingredient in recipe.ingredients:
		if ingredient == null or ingredient.item == null:
			continue
		if not inv.has_item(ingredient.item.item_id, ingredient.count):
			return false
	return true

func craft(recipe: RecipeData) -> bool:
	if not can_craft(recipe):
		return false

	var registry: Node = get_node("/root/ServiceRegistry")
	var inv: InventoryService = registry.inventory_service

	# Consume ingredients
	for ingredient in recipe.ingredients:
		if ingredient == null or ingredient.item == null:
			continue
		inv.remove_item_by_id(ingredient.item.item_id, ingredient.count)

	# Add result
	inv.add_item(recipe.result_item, recipe.result_count)
	_event_bus.recipe_crafted.emit(recipe.recipe_id, recipe.result_item.item_id, recipe.result_count)
	return true

func place_building(building_id: String, position: Vector2i) -> bool:
	_event_bus.building_placed.emit(building_id, building_id, position)
	return true
