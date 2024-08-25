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

func _ready() -> void:
	player.connect("died", Callable(self, "_on_player_died"))
	label.text = str(time_left)
	create_timer()


func update_z_index_by_group(group_name: String):
	for character in get_tree().get_nodes_in_group(group_name):
		character.z_index = max(5, int(character.position.y))


func _process(_delta: float) -> void:
	update_z_index_by_group("enemies_sprite")
	update_z_index_by_group("Player")
	if(!level_finished):
		pause_controller()


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
	music.stop()
	get_tree().call_group_flags(SceneTree.GROUP_CALL_DEFAULT, "enemies", "SET_lose", true)
	player.SET_pause_or_end(true)
	level_finished = true
	game_over.play()


func _on_button_restart_pressed() -> void:
	get_tree().reload_current_scene()


func _on_button_menu_pressed() -> void:
	get_tree().change_scene_to_packed(scene_Main_Menu)


func _on_button_next_pressed() -> void:
	get_tree().change_scene_to_packed(scene_Level_next)



func _on_game_over_finished() -> void:
	color.visible = true
	TRectLose.visible = true


func _on_win_finished() -> void:
	color.visible = true
	TRectWin.visible = true
