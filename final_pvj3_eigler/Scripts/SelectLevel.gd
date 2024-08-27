extends Control

var scene_Main_Menu = load("res://Scenes/MainMenu.tscn")
var scene_Level_01 = load("res://Scenes/Level_01.tscn")
var scene_Level_02 = load("res://Scenes/Level_02.tscn")

@onready var hover_sound = $Button_Hover


var buttons: Array[Button] = []
var current_button_index: int = 0


func _ready():
	btns_ready()
	for button in get_tree().get_nodes_in_group("button"):
		if button is Button:
			button.connect("mouse_entered", Callable(self, "_on_button_mouse_entered"))


func _process(delta: float) -> void:
	gp_process()


func _on_button_mouse_entered():
	hover_sound.play()


func btns_ready():
	var vbox_container = $CanvasLayer/PanelContainer/GridContainer
	for child in vbox_container.get_children():
		if child is Button:
			buttons.append(child)
	buttons.append($CanvasLayer/Button_Back)
	if buttons.size() > 0:
		buttons[current_button_index].grab_focus()


func gp_process():
	if Input.is_action_just_pressed("ui_down") || Input.is_action_just_pressed("ui_right"):
		move_focus(1)
	elif Input.is_action_just_pressed("ui_up") || Input.is_action_just_pressed("ui_left"):
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


func _on_button_back_pressed() -> void:
	get_tree().change_scene_to_packed(scene_Main_Menu)


func _on_button_level_01_pressed() -> void:
	get_tree().change_scene_to_packed(scene_Level_01)


func _on_button_level_02_pressed() -> void:
		get_tree().change_scene_to_packed(scene_Level_02)
