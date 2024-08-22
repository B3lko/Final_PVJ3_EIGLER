extends Control

var scene_menu = load("res://Scenes/MainMenu.tscn")

func _on_button_back_pressed() -> void:
	get_tree().change_scene_to_packed(scene_menu)
