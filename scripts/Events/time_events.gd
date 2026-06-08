class SolarTermEvent:
	var old_term: int
	var new_term: int
	var effect: Dictionary

	func _init(p_old_term: int, p_new_term: int, p_effect: Dictionary):
		old_term = p_old_term
		new_term = p_new_term
		effect = p_effect

class DayPhaseEvent:
	var old_phase: int
	var new_phase: int
	func _init(p_old: int, p_new: int):
		old_phase = p_old; new_phase = p_new

class SeasonEvent:
	var old_season: int
	var new_season: int
	func _init(p_old: int, p_new: int):
		old_season = p_old; new_season = p_new

class DayStartedEvent:
	var time: Dictionary
	func _init(p_time: Dictionary):
		time = p_time

class DayEndedEvent:
	var time: Dictionary
	func _init(p_time: Dictionary):
		time = p_time
