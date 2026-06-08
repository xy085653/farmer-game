extends Control
class_name MainMenu

@onready var new_game_btn: Button = $NewGameBtn
@onready var continue_btn: Button = $ContinueBtn
@onready var exit_btn: Button = $ExitBtn

func _ready() -> void:
	new_game_btn.pressed.connect(_on_new_game)
	continue_btn.pressed.connect(_on_continue)
	exit_btn.pressed.connect(_on_exit)

func _on_new_game() -> void:
	get_tree().change_scene_to_file("res://scenes/Game.tscn")

func _on_continue() -> void:
	get_tree().change_scene_to_file("res://scenes/Game.tscn")

func _on_exit() -> void:
	get_tree().quit()
