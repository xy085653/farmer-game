extends Control
class_name CraftingUI

@export var recipe_list: ItemList
@export var recipe_name_label: Label
@export var ingredient_label: Label
@export var craft_button: Button
@export var close_button: Button
@export var current_bench: int = RecipeData.WorkbenchType.NONE

var _registry: ServiceRegistry
var _selected_recipe: RecipeData

func _ready() -> void:
	_registry = get_node("/root/ServiceRegistry") as ServiceRegistry
	if craft_button:
		craft_button.pressed.connect(_on_craft_pressed)
	if close_button:
		close_button.pressed.connect(_close_crafting)
	if recipe_list:
		recipe_list.item_selected.connect(_on_recipe_selected)
	hide()

func open_crafting(bench: int) -> void:
	current_bench = bench
	visible = true
	_refresh_recipes()

func _refresh_recipes() -> void:
	if recipe_list:
		recipe_list.clear()
	if _registry == null or _registry.craft_service == null:
		return

	var recipes: Array[RecipeData] = _registry.craft_service.get_available_recipes(current_bench)
	for recipe in recipes:
		if recipe != null:
			recipe_list.add_item(recipe.recipe_name + " x" + str(recipe.result_count))

func _on_recipe_selected(index: int) -> void:
	if _registry == null or _registry.craft_service == null:
		return
	var recipes: Array[RecipeData] = _registry.craft_service.get_available_recipes(current_bench)
	if index < 0 or index >= recipes.size():
		return

	_selected_recipe = recipes[index]
	if recipe_name_label:
		recipe_name_label.text = _selected_recipe.recipe_name

	if ingredient_label:
		var text: String = "材料:\n"
		for ing in _selected_recipe.ingredients:
			if ing != null and ing.item != null:
				text += "  " + ing.item.item_name + " x" + str(ing.count) + "\n"
		ingredient_label.text = text

func _on_craft_pressed() -> void:
	if _selected_recipe == null:
		return
	if _registry and _registry.craft_service and _registry.craft_service.craft(_selected_recipe):
		print("制作成功: ", _selected_recipe.recipe_name)
		_refresh_recipes()

func _close_crafting() -> void:
	visible = false
