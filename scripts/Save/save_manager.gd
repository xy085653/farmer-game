extends Node
class_name SaveManager

const SAVE_PATH: String = "user://saves/save.dat"
const ENCRYPTION_KEY: String = "farm-game-key-v1"

var _registry: ServiceRegistry

func _ready() -> void:
	_registry = get_node("/root/ServiceRegistry") as ServiceRegistry
	var bus = get_node("/root/EventBus") as EventBus
	bus.day_ended.connect(func(_evt): save_game())

func save_game() -> void:
	var inv = _registry.inventory_service if _registry else null
	var time_svc = _registry.time_service if _registry else null
	var econ = _registry.economy_service if _registry else null

	if time_svc == null:
		return

	var time_dict: Dictionary = time_svc.current_time

	var save_data: Dictionary = {
		version = 1,
		year = time_dict.year,
		season = time_dict.season,
		term = time_dict.term,
		day_in_term = time_dict.day_in_term,
		minute = time_dict.minute,
		money = econ.money if econ else 0,
		inventory = _serialize_inventory(inv),
		player_pos = [400, 300],
		current_map = "farm"
	}

	# Ensure save directory exists
	var dir: DirAccess = DirAccess.open("user://")
	if dir == null:
		return
	if not dir.dir_exists("saves"):
		dir.make_dir("saves")

	# Encrypted write
	var file: FileAccess = FileAccess.open_encrypted_with_pass(SAVE_PATH, FileAccess.WRITE, ENCRYPTION_KEY)
	if file == null:
		print("保存失败: ", FileAccess.get_open_error())
		return

	file.store_var(save_data)
	file.close()
	print("游戏已保存")

func load_game() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		print("没有存档文件")
		return {}

	var file: FileAccess = FileAccess.open_encrypted_with_pass(SAVE_PATH, FileAccess.READ, ENCRYPTION_KEY)
	if file == null:
		print("加载失败: ", FileAccess.get_open_error())
		return {}

	var data: Dictionary = file.get_var() as Dictionary
	file.close()

	if data == null or data.is_empty():
		print("存档数据损坏")
		return {}

	return data

func _serialize_inventory(inv: InventoryService) -> Array:
	var result: Array = []
	if inv == null:
		return result

	for i in range(inv.slot_count):
		var slot: Dictionary = inv.get_slot(i)
		if slot.item == null or slot.count <= 0:
			continue
		result.append({
			slot = i,
			item_id = slot.item.item_id,
			count = slot.count
		})
	return result

func restore_game(data: Dictionary) -> void:
	pass  # Will be implemented when loading is needed

func has_save_file() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

func delete_save() -> void:
	if has_save_file():
		DirAccess.remove_absolute(SAVE_PATH)
