extends CharacterBody2D


var player: Node = null
@onready var animated_sprite = $AnimatedSprite2D
@export var damage = 50
var pause_or_end = false

@export var wait_explode = 3
@export var follow_time = 5

@onready var nav: NavigationAgent2D = $NavigationAgent2D
var moving = true
@export var SPEED = 11000

@onready var sfx_explosion = $Explosion

var current_animation: String

signal died

var isFollowing = false
var isPlayerOnArea = false
var isActivate = false

var paused_timer_time: float = 0.0
var timer

func _ready():
	var players = get_tree().get_nodes_in_group("Player")
	if players.size() > 0:
		player = players[0]


func _process(_delta: float) -> void:
	if(isFollowing && !pause_or_end):
		move(_delta)


func move(delta):
	var direction = Vector3()
	nav.target_position = player.position
	direction = nav.get_next_path_position() - global_position
	direction = direction.normalized()
		
	velocity = velocity.lerp(direction * SPEED * delta, 1 * delta)
	if (velocity.x < 0):
		animated_sprite.scale.x = -1;
	if (velocity.x > 0):
		animated_sprite.scale.x = 1;
	move_and_slide()
	if global_position.distance_to(player.position) < 10:
		moving = false
		velocity = Vector2.ZERO


func _on_animated_sprite_2d_animation_finished() -> void:
	if(animated_sprite.animation == "explode"):
		animated_sprite.play("fire")
	if(animated_sprite.animation == "awake"):
		start_follow()
	if(animated_sprite.animation == "hide"):
		animated_sprite.play("start_explode")
		timer = Timer.new()
		timer.wait_time = wait_explode
		timer.one_shot = true
		add_child(timer)
		timer.start()
		timer.connect("timeout", Callable(self, "explode"))


func SET_pause_or_end(state):
	pause_or_end = state
	if(state):
		current_animation = animated_sprite.animation
		animated_sprite.pause()
		if timer:
			timer.paused = true
	else:
		animated_sprite.play(current_animation)
		if timer:
			timer.paused = false


func SET_win(state):
	pause_or_end = state
	animated_sprite.play("explode")


func SET_lose(state):
	pause_or_end = state
	animated_sprite.play("celebrate")


func start_follow():
	timer = Timer.new()
	timer.wait_time = follow_time
	timer.one_shot = true
	add_child(timer)
	timer.start()
	timer.connect("timeout", Callable(self, "stop_follow"))
	isFollowing = true
	isActivate = true
	animated_sprite.play("walk")


func stop_follow():
	isFollowing = false
	animated_sprite.play("hide")


func explode():
	sfx_explosion.play()
	animated_sprite.play("explode")
	if(isPlayerOnArea):
		player.GetDamage(damage)


func _on_area_activate_body_entered(body: Node2D) -> void:
	if(body.is_in_group("Player") && !isActivate):
			animated_sprite.play("awake")


func _on_area_damage_body_entered(body: Node2D) -> void:
	if(body.is_in_group("Player")):
		isPlayerOnArea = true;


func _on_area_damage_body_exited(body: Node2D) -> void:
	if(body.is_in_group("Player")):
		isPlayerOnArea = false;


func _on_explosion_finished() -> void:
	emit_signal("died")
	queue_free()
