extends Control

var scene_menu = load("res://Scenes/MainMenu.tscn")

@onready var hover_sound = $Button_Hover
@onready var btn_back = $CanvasLayer/Button_back


func _ready():
	btn_back.grab_focus()
	for button in get_tree().get_nodes_in_group("button"):
		if button is Button:
			button.connect("mouse_entered", Callable(self, "_on_button_mouse_entered"))

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("enter"):
		btn_back.emit_signal("pressed")

func _on_button_mouse_entered():
	hover_sound.play()


func _on_button_back_pressed() -> void:
	get_tree().change_scene_to_packed(scene_menu)
