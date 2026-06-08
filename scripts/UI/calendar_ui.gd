extends Control
class_name CalendarUI

@export var term_grid: GridContainer
@export var current_term_label: Label
@export var effect_label: Label
@export var close_button: Button

const ALL_TERMS: Array[int] = [
	GameTimeResource.SolarTerm.LI_CHUN, GameTimeResource.SolarTerm.YU_SHUI,
	GameTimeResource.SolarTerm.JING_ZHE, GameTimeResource.SolarTerm.CHUN_FEN,
	GameTimeResource.SolarTerm.QING_MING, GameTimeResource.SolarTerm.GU_YU,
	GameTimeResource.SolarTerm.LI_XIA, GameTimeResource.SolarTerm.XIAO_MAN,
	GameTimeResource.SolarTerm.MANG_ZHONG, GameTimeResource.SolarTerm.XIA_ZHI,
	GameTimeResource.SolarTerm.XIAO_SHU, GameTimeResource.SolarTerm.DA_SHU,
	GameTimeResource.SolarTerm.LI_QIU, GameTimeResource.SolarTerm.CHU_SHU,
	GameTimeResource.SolarTerm.BAI_LU, GameTimeResource.SolarTerm.QIU_FEN,
	GameTimeResource.SolarTerm.HAN_LU, GameTimeResource.SolarTerm.SHUANG_JIANG,
	GameTimeResource.SolarTerm.LI_DONG, GameTimeResource.SolarTerm.XIAO_XUE,
	GameTimeResource.SolarTerm.DA_XUE, GameTimeResource.SolarTerm.DONG_ZHI,
	GameTimeResource.SolarTerm.XIAO_HAN, GameTimeResource.SolarTerm.DA_HAN
]

func _ready() -> void:
	if close_button:
		close_button.pressed.connect(_close_calendar)
	hide()
	_populate_grid()

func _populate_grid() -> void:
	if term_grid == null:
		return
	for term in ALL_TERMS:
		var label := Label.new()
		var season: int = GameTimeResource.get_season(term)
		var season_icon: String = ""
		match season:
			GameTimeResource.Season.SPRING: season_icon = "🌸"
			GameTimeResource.Season.SUMMER: season_icon = "☀️"
			GameTimeResource.Season.AUTUMN: season_icon = "🍂"
			GameTimeResource.Season.WINTER: season_icon = "❄️"
		label.text = season_icon + " " + GameTimeResource.get_display_name(term)
		term_grid.add_child(label)

func open_calendar() -> void:
	visible = true

func _close_calendar() -> void:
	visible = false
