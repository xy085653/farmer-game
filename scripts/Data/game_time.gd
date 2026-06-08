extends Resource
class_name GameTimeResource

enum Season { SPRING, SUMMER, AUTUMN, WINTER }
enum DayPhase { MORNING, NOON, EVENING, NIGHT }
enum SolarTerm {
	LI_CHUN, YU_SHUI, JING_ZHE, CHUN_FEN, QING_MING, GU_YU,
	LI_XIA, XIAO_MAN, MANG_ZHONG, XIA_ZHI, XIAO_SHU, DA_SHU,
	LI_QIU, CHU_SHU, BAI_LU, QIU_FEN, HAN_LU, SHUANG_JIANG,
	LI_DONG, XIAO_XUE, DA_XUE, DONG_ZHI, XIAO_HAN, DA_HAN
}

class GameTime:
	var year: int = 1
	var season: int = Season.SPRING
	var term: int = SolarTerm.LI_CHUN
	var day_in_term: int = 1
	var phase: int = DayPhase.MORNING
	var minute: int = 360

class SolarTermEffect:
	var growth_multiplier: float = 1.0
	var water_cost_multiplier: float = 1.0
	var price_multiplier: float = 1.0
	var description: String = ""

static func get_season(term: int) -> int:
	match term:
		SolarTerm.LI_CHUN, SolarTerm.YU_SHUI, SolarTerm.JING_ZHE, SolarTerm.CHUN_FEN, SolarTerm.QING_MING, SolarTerm.GU_YU:
			return Season.SPRING
		SolarTerm.LI_XIA, SolarTerm.XIAO_MAN, SolarTerm.MANG_ZHONG, SolarTerm.XIA_ZHI, SolarTerm.XIAO_SHU, SolarTerm.DA_SHU:
			return Season.SUMMER
		SolarTerm.LI_QIU, SolarTerm.CHU_SHU, SolarTerm.BAI_LU, SolarTerm.QIU_FEN, SolarTerm.HAN_LU, SolarTerm.SHUANG_JIANG:
			return Season.AUTUMN
		SolarTerm.LI_DONG, SolarTerm.XIAO_XUE, SolarTerm.DA_XUE, SolarTerm.DONG_ZHI, SolarTerm.XIAO_HAN, SolarTerm.DA_HAN:
			return Season.WINTER
	return Season.SPRING

static func get_display_name(term: int) -> String:
	match term:
		SolarTerm.LI_CHUN: return "立春"
		SolarTerm.YU_SHUI: return "雨水"
		SolarTerm.JING_ZHE: return "惊蛰"
		SolarTerm.CHUN_FEN: return "春分"
		SolarTerm.QING_MING: return "清明"
		SolarTerm.GU_YU: return "谷雨"
		SolarTerm.LI_XIA: return "立夏"
		SolarTerm.XIAO_MAN: return "小满"
		SolarTerm.MANG_ZHONG: return "芒种"
		SolarTerm.XIA_ZHI: return "夏至"
		SolarTerm.XIAO_SHU: return "小暑"
		SolarTerm.DA_SHU: return "大暑"
		SolarTerm.LI_QIU: return "立秋"
		SolarTerm.CHU_SHU: return "处暑"
		SolarTerm.BAI_LU: return "白露"
		SolarTerm.QIU_FEN: return "秋分"
		SolarTerm.HAN_LU: return "寒露"
		SolarTerm.SHUANG_JIANG: return "霜降"
		SolarTerm.LI_DONG: return "立冬"
		SolarTerm.XIAO_XUE: return "小雪"
		SolarTerm.DA_XUE: return "大雪"
		SolarTerm.DONG_ZHI: return "冬至"
		SolarTerm.XIAO_HAN: return "小寒"
		SolarTerm.DA_HAN: return "大寒"
	return "未知"

static func get_season_name(season: int) -> String:
	match season:
		Season.SPRING: return "春"
		Season.SUMMER: return "夏"
		Season.AUTUMN: return "秋"
		Season.WINTER: return "冬"
	return "未知"

static func get_phase_name(phase: int) -> String:
	match phase:
		DayPhase.MORNING: return "晨"
		DayPhase.NOON: return "午"
		DayPhase.EVENING: return "夕"
		DayPhase.NIGHT: return "夜"
	return "未知"
