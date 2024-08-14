extends CharacterBody2D

var HealthBar: Node = null
@export var SPEED: float = 200
@onready var animated_sprite = $AnimatedSprite2D
var isAttacking = false
var direccion = "right"
var life = 100;
var pause_or_end = false
var m_damage = 20 

var enemies_in_area: Array = []

signal died

@onready var CS2DAttack = $Area2D/CollisionShape2D

var is_blinking = false
var blink_duration = 1

func _ready():
	var HealthBars = get_tree().get_nodes_in_group("HealthBar")
	if HealthBars.size() > 0:
		HealthBar = HealthBars[0]
	CS2DAttack.shape.extents = Vector2(75, 30)
	CS2DAttack.position = Vector2(35, 0)


func GetDamage(damage):
	#Shader blink
	is_blinking = true
	var material = animated_sprite.material as ShaderMaterial
	material.set("shader_parameter/blink", 1.0)
	await get_tree().create_timer(blink_duration).timeout
	material.set("shader_parameter/blink", 0.0)
	is_blinking = false
	
	HealthBar.update_health_bar(damage)
	life -= damage
	
	if(life <= 0):
		emit_signal("died")
		print("Character is dead")


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
		#Ataque arriva
		if (direccion == "up"):
			var random_number = randi() % 2 + 1
			if(random_number == 1):
				animated_sprite.play("attack_up_01")
			else:
				animated_sprite.play("attack_up_02")
		
		#Ataque abajo
		if (direccion == "down"):
			var random_number = randi() % 2 + 1
			if(random_number == 1):
				animated_sprite.play("attack_down_01")
			else:
				animated_sprite.play("attack_down_02")
				
		#Ataque de izquierda y/o derecha
		if (direccion == "left" || direccion == "right"):
			var random_number = randi() % 2 + 1
			if(random_number == 1):
				animated_sprite.play("attack_01")
			else:
				animated_sprite.play("attack_02")


func move_character(delta):
	var input_direction = Input.get_vector("move_left", "move_right", "move_up", "move_bottom")
	velocity = input_direction * SPEED
	move_and_slide()
	#move_and_collide(velocity * delta)
	getDirection(input_direction)
	
func getDirection(input_direction):
	if abs(input_direction.x) > abs(input_direction.y):
		if input_direction.x > 0:
			CS2DAttack.shape.extents = Vector2(75, 30)
			CS2DAttack.position = Vector2(35, 0)
			direccion = "right"
		elif input_direction.x < 0:
			CS2DAttack.shape.extents = Vector2(75, 30)
			CS2DAttack.position = Vector2(-35, 0)
			direccion = "left"
	else:
		if input_direction.y < 0:
			CS2DAttack.shape.extents = Vector2(30, 75)
			CS2DAttack.position = Vector2(0, -35)
			direccion = "up"
		elif input_direction.y > 0:
			CS2DAttack.shape.extents = Vector2(30, 75)
			CS2DAttack.position = Vector2(0, 35)
			direccion = "down"


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
				body.GetDamage(m_damage)
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

