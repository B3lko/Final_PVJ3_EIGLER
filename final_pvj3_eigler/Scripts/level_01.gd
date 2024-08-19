extends Node2D

var scene_Main_Menu = load("res://Scenes/MainMenu.tscn")
var scene_Level_01 = load("res://Scenes/Level_01.tscn")
@onready var color = $CanvasLayer/ColorRect
@onready var TRectWin = $CanvasLayer/ColorRect/TextureRectWin
@onready var TRectLose = $CanvasLayer/ColorRect/TextureRectLose
@onready var TRectPause = $CanvasLayer/ColorRect/TextureRectPause
@onready var label = $CanvasLayer/Label
@onready var player = $Player

@export var time_left: int
var level_finished = false
var paused_timer_time: float = 0.0

var active_timer: SceneTreeTimer = null

@onready var spawner = $Enemy_Spawner


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
	
	if Input.is_action_just_pressed("pause"):
		if (level_finished):
			level_finished = false;
			color.visible = false
			TRectPause.visible = false
			spawner.resume_spawn_timers()
			get_tree().call_group_flags(SceneTree.GROUP_CALL_DEFAULT, "enemies", "SET_pause_or_end", false)
			player.SET_pause_or_end(false)
			if paused_timer_time > 0:
				active_timer = get_tree().create_timer(paused_timer_time)
				active_timer.connect("timeout", Callable(self, "_on_Timer_timeout"))
		else:
			level_finished = true
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
	if !level_finished:
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
	for node in get_tree().get_nodes_in_group("Sheep"):
		if node.has_method("_on_player_win"):
			node._on_player_win()
	get_tree().call_group_flags(SceneTree.GROUP_CALL_DEFAULT, "enemies", "SET_end", true)
	player.SET_pause_or_end(true)
	level_finished = true
	color.visible = true
	TRectWin.visible = true


func SetLoseLevel():
	get_tree().call_group_flags(SceneTree.GROUP_CALL_DEFAULT, "enemies", "SET_end", true)
	player.SET_pause_or_end(true)
	level_finished = true
	color.visible = true
	TRectLose.visible = true


func _on_button_restart_pressed() -> void:
	get_tree().change_scene_to_packed(scene_Level_01)	


func _on_button_menu_pressed() -> void:
	get_tree().change_scene_to_packed(scene_Main_Menu)
