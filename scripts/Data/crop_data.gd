extends Resource
class_name CropData

@export var crop_id: String = ""
@export var crop_name: String = ""
@export var seed_item: ItemData
@export var harvest_item: ItemData
@export var base_growth_days: float = 5.0
@export var growth_stages: int = 5
@export var stage_sprites: Array[Texture2D] = []
@export var preferred_terms: Array[int] = []
@export var can_regrow: bool = false
@export var regrow_days: int = 3
@export var harvest_count: int = 1
@export var allowed_seasons: Array[int] = []
