extends Control

var scene_Select_Level = load("res://Scenes/SelectLevel.tscn")

func _on_button_play_pressed() -> void:
	get_tree().change_scene_to_packed(scene_Select_Level)

func _on_button_quit_pressed() -> void:
	get_tree().quit()
