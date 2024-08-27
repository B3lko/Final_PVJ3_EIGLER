extends Node2D

#Varian entre niveles
@export var scene_Level_next: PackedScene
@export var time_left: int

var scene_Main_Menu = load("res://Scenes/MainMenu.tscn")

@onready var color = $CanvasLayer/ColorRect
@onready var TRectWin = $CanvasLayer/ColorRect/TextureRectWin
@onready var TRectLose = $CanvasLayer/ColorRect/TextureRectLose
@onready var TRectPause = $CanvasLayer/ColorRect/TextureRectPause
@onready var label = $CanvasLayer/Label
@onready var player = $Player

var level_finished = false
var is_pause = false
var paused_timer_time: float = 0.0
var active_timer: SceneTreeTimer = null

@onready var spawner = $Enemy_Spawner
@onready var pause_on = $Pause_On
@onready var pause_off = $Pause_Off
@onready var game_over = $Game_over
@onready var fanfare = $Win
@onready var music = $Music

@onready var Spawner = $Enemy_Spawner

var buttons: Array[Button] = []
var current_button_index: int = 0

var aux = true

var cursor_speed = 400.0

func _ready() -> void:
	update_active_buttons()
	AudioManager.stop_audio()
	player.connect("died", Callable(self, "_on_player_died"))
	label.text = str(time_left)
	create_timer()


func update_z_index_by_group(group_name: String):
	for character in get_tree().get_nodes_in_group(group_name):
		character.z_index = max(5, int(character.position.y))


func _process(_delta: float) -> void:
	update_cursor_gp(_delta)
	btn_process()
	if aux:
		update_z_index_by_group("enemies_sprite")
		update_z_index_by_group("Player")
	if(!level_finished):
		pause_controller()


func update_cursor_gp(delta):
	 # Obtener las entradas de la palanca izquierda del gamepad
	var left_stick_x = Input.get_action_strength("right_stick_right") - Input.get_action_strength("right_stick_left")
	var left_stick_y = Input.get_action_strength("right_stick_down") - Input.get_action_strength("right_stick_up")
	
	# Calcular la nueva posición del cursor
	var mouse_position = get_viewport().get_mouse_position()
	var new_position = mouse_position + Vector2(left_stick_x, left_stick_y) * cursor_speed * delta
	
	# Limitar el cursor a la ventana de la pantalla
	new_position.x = clamp(new_position.x, 0, get_viewport().size.x)
	new_position.y = clamp(new_position.y, 0, get_viewport().size.y)
	
	# Mover el cursor a la nueva posición
	get_viewport().warp_mouse(new_position)


func btn_process():
	if buttons.size() == 0:
		return
	if Input.is_action_just_pressed("ui_down") || Input.is_action_just_pressed("ui_right"):
		move_focus(1)
	elif Input.is_action_just_pressed("ui_up") || Input.is_action_just_pressed("ui_left"):
		move_focus(-1)
	elif Input.is_action_just_pressed("enter"):
		aux = false
		buttons[current_button_index].emit_signal("pressed")


func pause_controller():
	if Input.is_action_just_pressed("pause"):
		if (is_pause):
			is_pause = false
			pause_off.play()
			color.visible = false
			TRectPause.visible = false
			spawner.resume_spawn_timers()
			get_tree().call_group_flags(SceneTree.GROUP_CALL_DEFAULT, "enemies", "SET_pause_or_end", false)
			player.SET_pause_or_end(false)
			if paused_timer_time > 0:
				active_timer = get_tree().create_timer(paused_timer_time)
				active_timer.connect("timeout", Callable(self, "_on_Timer_timeout"))
		else:
			is_pause = true
			pause_on.play()
			color.visible = true
			TRectPause.visible = true
			spawner.pause_spawn_timers()
			get_tree().call_group_flags(SceneTree.GROUP_CALL_DEFAULT, "enemies", "SET_pause_or_end", true)
			player.SET_pause_or_end(true)
			update_active_buttons()
			if active_timer:
				paused_timer_time = active_timer.time_left
				active_timer = null


func create_timer() -> void:
	active_timer = get_tree().create_timer(1.0)
	active_timer.connect("timeout", Callable(self, "_on_Timer_timeout"))


func _on_Timer_timeout() -> void:
	if !level_finished && !is_pause:
		if time_left > 0:
			time_left -= 1
			label.text = str(time_left)
			if time_left > 0:
				create_timer()
		if (time_left == 0):
			SetWinLevel()


func _on_player_died() -> void:
	if !level_finished:
		SetLoseLevel()


func SetWinLevel():
	Spawner.ready_start = false
	music.stop()
	for node in get_tree().get_nodes_in_group("Sheep"):
		if node.has_method("_on_player_win"):
			node._on_player_win()
	get_tree().call_group_flags(SceneTree.GROUP_CALL_DEFAULT, "enemies", "SET_win", true)
	player.SET_pause_or_end(true)
	player.set_win()
	level_finished = true
	fanfare.play()


func SetLoseLevel():
	Spawner.ready_start = false
	music.stop()
	get_tree().call_group_flags(SceneTree.GROUP_CALL_DEFAULT, "enemies", "SET_lose", true)
	player.SET_pause_or_end(true)
	level_finished = true
	game_over.play()


func update_active_buttons():
	buttons.clear()
	current_button_index = 0
	if $CanvasLayer/ColorRect/TextureRectPause.visible:
		add_buttons_from_container($CanvasLayer/ColorRect/TextureRectPause/GridContainer)
	elif $CanvasLayer/ColorRect/TextureRectWin.visible:
		add_buttons_from_container($CanvasLayer/ColorRect/TextureRectWin/GridContainer)
	elif $CanvasLayer/ColorRect/TextureRectLose.visible:
		add_buttons_from_container($CanvasLayer/ColorRect/TextureRectLose/GridContainer)
	if buttons.size() > 0:
		buttons[current_button_index].grab_focus()


func add_buttons_from_container(container: Node):
	for child in container.get_children():
		if child is Button:
			buttons.append(child)


func move_focus(direction: int):
	buttons[current_button_index].release_focus()
	current_button_index += direction
	if current_button_index >= buttons.size():
		current_button_index = 0
	elif current_button_index < 0:
		current_button_index = buttons.size() - 1
	buttons[current_button_index].grab_focus()


func _on_button_restart_pressed() -> void:
	get_tree().reload_current_scene()


func _on_button_menu_pressed() -> void:
	get_tree().change_scene_to_packed(scene_Main_Menu)


func _on_button_next_pressed() -> void:
	get_tree().change_scene_to_packed(scene_Level_next)


func _on_game_over_finished() -> void:
	color.visible = true
	TRectLose.visible = true
	update_active_buttons()


func _on_win_finished() -> void:
	color.visible = true
	TRectWin.visible = true
	update_active_buttons()
