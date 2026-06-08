extends Node
class_name TimeService

const REAL_SECONDS_PER_GAME_MINUTE: float = 0.5

var _event_bus: EventBus
var _current_time: Dictionary = {
	year = 1,
	season = GameTimeResource.Season.SPRING,
	term = GameTimeResource.SolarTerm.LI_CHUN,
	day_in_term = 1,
	phase = GameTimeResource.DayPhase.MORNING,
	minute = 360
}
var _elapsed_time: float = 0.0
var _time_scale: float = 1.0

var current_time: Dictionary:
	get: return _current_time.duplicate()

var current_term: int:
	get: return _current_time.term

var time_scale: float:
	get: return _time_scale
	set(v): _time_scale = max(0.0, v)

func _ready() -> void:
	_event_bus = get_node("/root/EventBus") as EventBus

func _process(delta: float) -> void:
	var dt: float = delta
	_elapsed_time += dt
	var adjusted_interval: float = REAL_SECONDS_PER_GAME_MINUTE / _time_scale

	while _elapsed_time >= adjusted_interval:
		_elapsed_time -= adjusted_interval
		_tick_minute()

func _tick_minute() -> void:
	_current_time.minute += 1
	if _current_time.minute >= 1440:
		_end_day()
		return

	var new_phase: int = _get_phase_for_minute(_current_time.minute)
	if new_phase != _current_time.phase:
		var old_phase: int = _current_time.phase
		_current_time.phase = new_phase
		_event_bus.phase_changed.emit(old_phase, new_phase)

static func _get_phase_for_minute(minute: int) -> int:
	if minute < 600: return GameTimeResource.DayPhase.MORNING
	if minute < 960: return GameTimeResource.DayPhase.NOON
	if minute < 1200: return GameTimeResource.DayPhase.EVENING
	return GameTimeResource.DayPhase.NIGHT

func _end_day() -> void:
	var old_time: Dictionary = _current_time.duplicate()
	_event_bus.day_ended.emit(old_time)

	_current_time.minute = 360
	_current_time.day_in_term += 1

	if _current_time.day_in_term > 3:
		_advance_term()

	_current_time.phase = GameTimeResource.DayPhase.MORNING
	_event_bus.day_started.emit(_current_time.duplicate())

func _advance_term() -> void:
	_current_time.day_in_term = 1
	var old_term: int = _current_time.term
	var next_term_value: int = old_term + 1

	if next_term_value > GameTimeResource.SolarTerm.DA_HAN:
		next_term_value = GameTimeResource.SolarTerm.LI_CHUN
		_current_time.year += 1

	_current_time.term = next_term_value

	var old_season: int = GameTimeResource.get_season(old_term)
	var new_season: int = GameTimeResource.get_season(next_term_value)

	var effect: Dictionary = _get_effect_for_term(next_term_value)
	_event_bus.solar_term_changed.emit(old_term, next_term_value, effect)

	if old_season != new_season:
		_current_time.season = new_season
		_event_bus.season_changed.emit(old_season, new_season)

func advance_phase() -> void:
	match _current_time.phase:
		GameTimeResource.DayPhase.MORNING:
			_current_time.minute = 600
			_current_time.phase = GameTimeResource.DayPhase.NOON
			_event_bus.phase_changed.emit(GameTimeResource.DayPhase.MORNING, GameTimeResource.DayPhase.NOON)
		GameTimeResource.DayPhase.NOON:
			_current_time.minute = 960
			_current_time.phase = GameTimeResource.DayPhase.EVENING
			_event_bus.phase_changed.emit(GameTimeResource.DayPhase.NOON, GameTimeResource.DayPhase.EVENING)
		GameTimeResource.DayPhase.EVENING:
			_current_time.minute = 1200
			_current_time.phase = GameTimeResource.DayPhase.NIGHT
			_event_bus.phase_changed.emit(GameTimeResource.DayPhase.EVENING, GameTimeResource.DayPhase.NIGHT)
		GameTimeResource.DayPhase.NIGHT:
			_end_day()

func advance_to_next_day() -> void:
	_end_day()

func get_current_term_effect() -> Dictionary:
	return _get_effect_for_term(_current_time.term)

static func _get_effect_for_term(term: int) -> Dictionary:
	var effect: Dictionary = {
		growth_multiplier = 1.0,
		water_cost_multiplier = 1.0,
		price_multiplier = 1.0,
		description = ""
	}

	match term:
		GameTimeResource.SolarTerm.LI_CHUN:
			effect.growth_multiplier = 1.2
			effect.water_cost_multiplier = 0.5
			effect.description = "立春: 耕地不耗体力"
		GameTimeResource.SolarTerm.GU_YU:
			effect.growth_multiplier = 1.3
			effect.water_cost_multiplier = 0.8
			effect.description = "谷雨: 宜播种，作物生长加速"
		GameTimeResource.SolarTerm.DA_SHU:
			effect.growth_multiplier = 1.1
			effect.water_cost_multiplier = 0.5
			effect.description = "大暑: 浇水需求减半"
		GameTimeResource.SolarTerm.SHUANG_JIANG:
			effect.growth_multiplier = 0.5
			effect.description = "霜降: 作物可能冻死"
		GameTimeResource.SolarTerm.DONG_ZHI:
			effect.growth_multiplier = 0.0
			effect.price_multiplier = 1.2
			effect.description = "冬至: 万物休养，物价上升"

	return effect
