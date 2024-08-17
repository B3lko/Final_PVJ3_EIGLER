extends Control

var scene_Main_Menu = load("res://Scenes/MainMenu.tscn")
var scene_Level_01 = load("res://Scenes/Level_01.tscn")

func _on_button_back_pressed() -> void:
	get_tree().change_scene_to_packed(scene_Main_Menu)

func _on_button_level_01_pressed() -> void:
	get_tree().change_scene_to_packed(scene_Level_01)
