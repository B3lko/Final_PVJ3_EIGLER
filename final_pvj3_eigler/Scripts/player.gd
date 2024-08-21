extends CharacterBody2D

var HealthBar: Node = null
@export var SPEED: float = 200
@onready var animated_sprite = $AnimatedSprite2D
var isAttacking = false
var direction = "right"
@export var life = 100;
var pause_or_end = false
@export var m_damage = 20 

var enemies_in_area: Array = []

signal died

@onready var CS2DAttack = $Area2D/CollisionShape2D

var is_blinking = false
@export var blink_duration = 1

var force: Vector2
@export var force_value = 250

var is_flashing = false
@export var flash_duration = 0.2

@onready var Sword_1 = $Sword_1
@onready var Sword_2 = $Sword_2
@onready var Walk_Grass = $GrassWalk
@onready var Scream1 = $Scream1
@onready var Scream2 = $Scream2
@onready var Scream3 = $Scream3

func _ready():
	var HealthBars = get_tree().get_nodes_in_group("HealthBar")
	if HealthBars.size() > 0:
		HealthBar = HealthBars[0]
	CS2DAttack.shape.extents = Vector2(75, 30)
	CS2DAttack.position = Vector2(35, 0)


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
	

	
	if(life <= 0):
		emit_signal("died")


func GetLife(_life):
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
		var random_number = randi() % 2 + 1
		if(random_number == 1):
			Sword_2.play()
		else:
			Sword_1.play()
		#Ataque arriva
		if (direction == "up"):
			if(random_number == 1):
				animated_sprite.play("attack_up_01")
			else:
				animated_sprite.play("attack_up_02")
		
		#Ataque abajo
		if (direction == "down"):
			if(random_number == 1):
				animated_sprite.play("attack_down_01")
			else:
				animated_sprite.play("attack_down_02")
				
		#Ataque de izquierda y/o derecha
		if (direction == "left" || direction == "right"):
			if(random_number == 1):
				animated_sprite.play("attack_01")
			else:
				animated_sprite.play("attack_02")


func move_character(_delta):
	var input_direction = Input.get_vector("move_left", "move_right", "move_up", "move_bottom")
	velocity = input_direction * SPEED
	move_and_slide()
	getDirection(input_direction)
	
func getDirection(input_direction):
	if (input_direction.x != 0 || input_direction.y != 0):
		if(!Walk_Grass.is_playing()):
			Walk_Grass.play()
	if abs(input_direction.x) > abs(input_direction.y):
		if input_direction.x > 0:
			force = Vector2(force_value, 0)						
			CS2DAttack.shape.extents = Vector2(60, 30)
			CS2DAttack.position = Vector2(35, 0)
			direction = "right"
		elif input_direction.x < 0:
			force = Vector2(-force_value, 0)			
			CS2DAttack.shape.extents = Vector2(60, 30)
			CS2DAttack.position = Vector2(-35, 0)
			direction = "left"
	else:
		if input_direction.y < 0:
			force = Vector2(0, -force_value)			
			CS2DAttack.shape.extents = Vector2(30, 60)
			CS2DAttack.position = Vector2(0, -35)
			direction = "up"
		elif input_direction.y > 0:
			force = Vector2(0, force_value)			
			CS2DAttack.shape.extents = Vector2(30, 60)
			CS2DAttack.position = Vector2(0, 35)
			direction = "down"


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
	|| animated_sprite.animation == "attack_02"
	|| animated_sprite.animation == "attack_down_01"
	|| animated_sprite.animation == "attack_down_02"
	|| animated_sprite.animation == "attack_up_01"
	|| animated_sprite.animation == "attack_up_02"):
		for body in enemies_in_area:
			if body.has_method("GetDamage"):
				#Sword_1.play()
				body.GetDamage(m_damage)
				body.velocity += force				
		isAttacking = false
		animated_sprite.play("idle")	


func SET_pause_or_end(state):
	pause_or_end = state


func _on_area_2d_body_entered(body: Node2D) -> void:
	if (body.is_in_group("enemies")):
		enemies_in_area.append(body)


func _on_area_2d_body_exited(body: Node2D) -> void:
	if enemies_in_area.has(body):
		enemies_in_area.erase(body)


func _on_area_2d_get_items_area_entered(area: Area2D) -> void:
	if (area.is_in_group("steak")):
		GetLife(area.get_parent().life)
		area.get_parent().queue_free()
