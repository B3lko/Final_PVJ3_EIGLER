extends Control

var scene_Select_Level = load("res://Scenes/SelectLevel.tscn")
var scene_options = load("res://Scenes/Options.tscn")
var scene_credits = load("res://Scenes/credits.tscn")
@onready var hover_sound = $Button_Hover

var config_file_path: String = "user://audio_settings.json"


var buttons: Array[Button] = []
var current_button_index: int = 0


func _ready():
	btns_ready()
	AudioManager.play_audio()
	for button in get_tree().get_nodes_in_group("button"):
		if button is Button:
			button.connect("mouse_entered", Callable(self, "_on_button_mouse_entered"))
	apply_audio_settings("Master")
	apply_audio_settings("Music")
	apply_audio_settings("SFX")


func btns_ready():
	var vbox_container = $CanvasLayer/VBoxContainer
	for child in vbox_container.get_children():
		if child is Button:
			buttons.append(child)
	if buttons.size() > 0:
		buttons[current_button_index].grab_focus()


func _process(_delta: float) -> void:
	gp_process()


func apply_audio_settings(bus_name: String) -> void:
	var config = load_audio_settings()
	var bus_index = AudioServer.get_bus_index(bus_name)

	if bus_name in config:
		var db_value = config[bus_name]
		AudioServer.set_bus_volume_db(bus_index, db_value)
	else:
		var default_db = AudioServer.get_bus_volume_db(bus_index)
		AudioServer.set_bus_volume_db(bus_index, default_db)


func load_audio_settings() -> Dictionary:
	if FileAccess.file_exists(config_file_path):
		var file = FileAccess.open(config_file_path, FileAccess.READ)
		var content = file.get_as_text()
		file.close()
		var parse_result = JSON.parse_string(content)
		if typeof(parse_result) == TYPE_DICTIONARY:
			return parse_result
	return {}


func _on_button_mouse_entered():
	hover_sound.play()


func _on_button_play_pressed() -> void:
	get_tree().change_scene_to_packed(scene_Select_Level)


func _on_button_quit_pressed() -> void:
	get_tree().quit()


func _on_button_options_pressed() -> void:
	get_tree().change_scene_to_packed(scene_options)


func _on_button_credits_pressed() -> void:
	get_tree().change_scene_to_packed(scene_credits)


func gp_process():
	if Input.is_action_just_pressed("ui_down"):
		move_focus(1)
	elif Input.is_action_just_pressed("ui_up"):
		move_focus(-1)
	elif Input.is_action_just_pressed("enter"):
		buttons[current_button_index].emit_signal("pressed")


func move_focus(direction: int):
	buttons[current_button_index].release_focus()
	current_button_index += direction
	if current_button_index >= buttons.size():
		current_button_index = 0
	elif current_button_index < 0:
		current_button_index = buttons.size() - 1
	buttons[current_button_index].grab_focus()
