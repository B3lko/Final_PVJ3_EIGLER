extends CanvasLayer

@onready var hover_sound = $"../Button_Hover"
@onready var click_sound = $"../Button_Click"

func _ready():
	# Recorre todos los nodos hijos que sean botones
	for button in get_tree().get_nodes_in_group("button"):
		if button is Button:
			button.connect("mouse_entered", Callable(self, "_on_button_mouse_entered"))
			button.connect("pressed", Callable(self, "_on_button_pressed"))

func _on_button_mouse_entered():
	hover_sound.play()

func _on_button_pressed():
	click_sound.play()
