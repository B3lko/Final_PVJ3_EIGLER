extends Control

var scene_Main_Menu = load("res://Scenes/MainMenu.tscn")
var scene_Level_01 = load("res://Scenes/Level_01.tscn")
var scene_Level_02 = load("res://Scenes/Level_02.tscn")

@onready var hover_sound = $Button_Hover


func _ready():
	for button in get_tree().get_nodes_in_group("button"):
		if button is Button:
			button.connect("mouse_entered", Callable(self, "_on_button_mouse_entered"))


func _on_button_mouse_entered():
	hover_sound.play()


func _on_button_back_pressed() -> void:
	get_tree().change_scene_to_packed(scene_Main_Menu)


func _on_button_level_01_pressed() -> void:
	get_tree().change_scene_to_packed(scene_Level_01)


func _on_button_level_02_pressed() -> void:
		get_tree().change_scene_to_packed(scene_Level_02)
