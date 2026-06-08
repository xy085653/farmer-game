extends Resource
class_name ItemData

enum ItemType { SEED, PRODUCT, TOOL, MATERIAL, CRAFTED, SPECIAL }
enum ToolType { HOE, WATERING_CAN, AXE, PICKAXE, SCYTHE }

@export var item_id: String = ""
@export var item_name: String = ""
@export var description: String = ""
@export var type: ItemType = ItemType.SEED
@export var tool_sub_type: ToolType = ToolType.HOE
@export var base_price: int = 0
@export var max_stack: int = 99
@export var icon: Texture2D
@export var upgrade_level: int = 0
@export var energy_cost: int = 0
