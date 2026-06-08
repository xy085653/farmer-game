extends Resource
class_name RecipeData

enum WorkbenchType { NONE, KITCHEN, WORKSHOP, OUTDOOR }

@export var recipe_id: String = ""
@export var recipe_name: String = ""
@export var result_item: ItemData
@export var result_count: int = 1
@export var ingredients: Array[Ingredient] = []
@export var workbench: WorkbenchType = WorkbenchType.NONE
@export var required_tool_level: int = 0
@export var description: String = ""
