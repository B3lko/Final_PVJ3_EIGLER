extends Control

var scene_menu = load("res://Scenes/MainMenu.tscn")

@onready var hover_sound = $Button_Hover
@onready var btn_FS = $CanvasLayer/PanelContainer2/VBoxContainer/FullScreen
var isFS

func _ready():
	if(DisplayServer.WINDOW_MODE_FULLSCREEN == DisplayServer.window_get_mode()):
		isFS = true
	else:
		isFS = false
	for button in get_tree().get_nodes_in_group("button"):
		if button is Button:
			button.connect("mouse_entered", Callable(self, "_on_button_mouse_entered"))


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
