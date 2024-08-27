extends Control

var scene_menu = load("res://Scenes/MainMenu.tscn")

@onready var hover_sound = $Button_Hover
@onready var btn_FS = $CanvasLayer/PanelContainer2/VBoxContainer/FullScreen
var isFS

var controls: Array[Control] = []
var current_control_index: int = 0


func _ready():
	btn_Ready()
	if(DisplayServer.WINDOW_MODE_FULLSCREEN == DisplayServer.window_get_mode()):
		isFS = true
	else:
		isFS = false
	for button in get_tree().get_nodes_in_group("button"):
		if button is Button:
			button.connect("mouse_entered", Callable(self, "_on_button_mouse_entered"))


func btn_Ready():
	var container1 = $CanvasLayer/GridContainer/PanelContainer/VBoxContainer
	var container2 = $CanvasLayer/GridContainer/PanelContainer2/VBoxContainer
		
	for child in container1.get_children():
		if child is Button or child is HSlider:
			controls.append(child)
			
	for child in container2.get_children():
		if child is Button or child is HSlider:
			controls.append(child)
		
	controls.append($CanvasLayer/Button_back)
	if controls.size() > 0:
		controls[current_control_index].grab_focus()


func _process(delta):
	if Input.is_action_just_pressed("ui_down"):
		move_focus(1)
	elif Input.is_action_just_pressed("ui_up"):
		move_focus(-1)
	elif Input.is_action_just_pressed("enter"):
		if controls[current_control_index] is Button:
			controls[current_control_index].emit_signal("pressed")
	elif Input.is_action_pressed("ui_right"):
		if controls[current_control_index] is HSlider:
			adjust_slider(4)
	elif Input.is_action_pressed("ui_left"):
		if controls[current_control_index] is HSlider:
			adjust_slider(-4)


func _on_button_mouse_entered():
	hover_sound.play()


func _on_button_back_pressed() -> void:
	get_tree().change_scene_to_packed(scene_menu)


func _on_full_screen_pressed() -> void:
	if !isFS:
		isFS = !isFS
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		isFS = !isFS
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


func move_focus(direction: int):
	controls[current_control_index].release_focus()
	current_control_index += direction
	if current_control_index >= controls.size():
		current_control_index = 0
	elif current_control_index < 0:
		current_control_index = controls.size() - 1
	controls[current_control_index].grab_focus()


func adjust_slider(value: int):
	var slider = controls[current_control_index] as HSlider
	slider.value += value * slider.step
