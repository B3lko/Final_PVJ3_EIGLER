extends Control

var scene_Select_Level = load("res://Scenes/SelectLevel.tscn")
var scene_options = load("res://Scenes/Options.tscn")
@onready var hover_sound = $Button_Hover


func _ready():
	for button in get_tree().get_nodes_in_group("button"):
		if button is Button:
			button.connect("mouse_entered", Callable(self, "_on_button_mouse_entered"))


func _on_button_mouse_entered():
	hover_sound.play()


func _on_button_play_pressed() -> void:
	get_tree().change_scene_to_packed(scene_Select_Level)


func _on_button_quit_pressed() -> void:
	get_tree().quit()


func _on_button_options_pressed() -> void:
	get_tree().change_scene_to_packed(scene_options)


func _on_button_credits_pressed() -> void:
	pass # Replace with function body.
