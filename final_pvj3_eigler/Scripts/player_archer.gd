extends CharacterBody2D

var HealthBar: Node = null
@export var SPEED: float = 200
@onready var animated_sprite = $AnimatedSprite2D
var isAttacking = false
var direction = "right"
@export var life = 100;
var pause_or_end = false
@export var m_damage = 20 

signal died

var is_blinking = false
@export var blink_duration = 1

var force: Vector2
@export var force_value = 250

var is_flashing = false
@export var flash_duration = 0.2

@onready var Arrow = $arrow
@onready var Walk_Grass = $GrassWalk
@onready var Scream1 = $Scream1
@onready var Scream2 = $Scream2
@onready var Scream3 = $Scream3
@onready var Steak = $Steak

var is_dead = false

const arrow = preload("res://Scenes/arrow.tscn")

func _ready():
	var HealthBars = get_tree().get_nodes_in_group("HealthBar")
	if HealthBars.size() > 0:
		HealthBar = HealthBars[0]



func GetDamage(damage):
	if(!Scream1.is_playing() && !Scream2.is_playing() && !Scream3.is_playing()):
			var random_number = randi() % 3 + 1
			if(random_number == 1):
				Scream1.play()
			elif(random_number == 2):
				Scream2.play()
			else:
				Scream3.play()
	#Shader blink
	is_blinking = true
	var material = animated_sprite.material as ShaderMaterial
	material.set("shader_parameter/blink", 1.0)
	await get_tree().create_timer(blink_duration).timeout
	material.set("shader_parameter/blink", 0.0)
	is_blinking = false
	
	life -= damage
	HealthBar.update_health_bar(life)
	

	
	if(life <= 0 && !is_dead):
		is_dead = true
		emit_signal("died")
		animated_sprite.play("death")


func GetLife(_life):
	Steak.play()
	if not is_flashing:
		is_flashing = true
		var material = animated_sprite.material as ShaderMaterial
		material.set("shader_parameter/damage_flash", 1.0)
		await get_tree().create_timer(flash_duration).timeout
		material.set("shader_parameter/damage_flash", 0.0)
		is_flashing = false
	life += _life
	if (life > 100):
		life = 100
	HealthBar.update_health_bar(life)


func shoot():
	var dif_x = get_global_mouse_position().x - position.x
	var dif_y = get_global_mouse_position().y - position.y
	var ang_rad = atan2(dif_x, dif_y)
	var ang_deg = rad_to_deg(ang_rad)
	ang_deg -= 90
	if ang_deg < 0:
		ang_deg += 360
	ang_deg = deg_to_rad(ang_deg)
	var disparo = arrow.instantiate()
	disparo.init(ang_deg, position.x, position.y, name)
	get_parent().add_child(disparo)


func _physics_process(delta):
	if !pause_or_end:
		if (!isAttacking):
			move_character(delta)
		update_animations()
		attack()


func _process(delta: float) -> void:
	ShaderUpdate(delta)


func ShaderUpdate(delta):
	if is_blinking:
		var material = animated_sprite.material as ShaderMaterial
		material.set("shader_parameter/blink", 1.0)
		material.set("shader_parameter/blink_time", material.get("shader_parameter/blink_time") + delta)
	else:
		var material = animated_sprite.material as ShaderMaterial
		material.set("shader_parameter/blink_time", 0.0)


func attack():
	if (Input.is_action_pressed("attack") && !isAttacking):
		isAttacking = true
		if (direction == "up"):
			animated_sprite.play("attack_up_01")
		elif (direction == "down"):
			animated_sprite.play("attack_down_01")
		elif (direction == "left"):
			animated_sprite.scale.x = -1;
			animated_sprite.play("attack_01")
		elif (direction == "right"):
			animated_sprite.scale.x = 1;			
			animated_sprite.play("attack_01")


func move_character(_delta):
	var input_direction = Input.get_vector("move_left", "move_right", "move_up", "move_bottom")
	velocity = input_direction * SPEED
	move_and_slide()
	get_direction(input_direction)
	
func get_direction(input_direction):
	var mouse_position = get_global_mouse_position()
	var player_position = global_position
	var direction_vector = mouse_position - player_position
	if abs(direction_vector.x) > abs(direction_vector.y):
		if direction_vector.x > 0:
			direction = "right"
		else:
			direction = "left"
	else:
		if direction_vector.y < 0:
			direction = "up"
		else:
			direction = "down"
	if (input_direction.x != 0 || input_direction.y != 0):
		if !Walk_Grass.is_playing():
			Walk_Grass.play()


func update_animations():
	if velocity.y != 0 && !isAttacking:
		animated_sprite.play("walk")		
	if velocity.x > 0 && !isAttacking:
		animated_sprite.scale.x = 1;
		animated_sprite.play("walk")
	if velocity.x < 0 && !isAttacking:
		animated_sprite.scale.x = -1;		
		animated_sprite.play("walk")
	if (velocity.x == 0 && velocity.y == 0 && !isAttacking):
		animated_sprite.play("idle")


func _on_animated_sprite_2d_animation_finished() -> void:
	if(animated_sprite.animation == "attack_01"
	|| animated_sprite.animation == "attack_down_01"
	|| animated_sprite.animation == "attack_up_01"):
		shoot()
		Arrow.play()		
		isAttacking = false
		animated_sprite.play("idle")	


func SET_pause_or_end(state):
	pause_or_end = state	


func set_win():
	animated_sprite.play("celebrate")


func _on_area_2d_get_items_area_entered(area: Area2D) -> void:
	if (area.is_in_group("steak")):
		GetLife(area.get_parent().life)
		area.get_parent().queue_free()
