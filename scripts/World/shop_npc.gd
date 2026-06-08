extends StaticBody2D
class_name ShopNPC

@export var shop_name: String = "杂货铺"
@export var shop_items: Array[ItemData] = []

func interact() -> void:
	print("打开 ", shop_name)
	# UI integration will be added later
