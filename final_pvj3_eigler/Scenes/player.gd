extends CharacterBody2D

var HealthBar: Node = null
@export var SPEED: float = 200
@onready var animated_sprite = $AnimatedSprite2D
var isAttacking = false
var direccion = "right"
var life = 100;

func _ready():
	var HealthBars = get_tree().get_nodes_in_group("HealthBar")
	if HealthBars.size() > 0:
		HealthBar = HealthBars[0]


func GetDamage(damage):
	HealthBar.update_health_bar(damage)
	life -= damage
	if(life <= 0):
		print("Character is dead")

func _physics_process(delta):
	if (!isAttacking):
		move_character(delta)
	update_animations()
	attack()

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

		#Ataque de izquierda o derecha
		if (direccion == "right" || direccion == "left"):
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
			#print("right")
			direccion = "right"			
		elif input_direction.x < 0:
			#print("left")
			direccion = "left"
	else:
		if input_direction.y < 0:
			#print("up")
			direccion = "up"
		elif input_direction.y > 0:
			#print("down")
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
		isAttacking = false
		animated_sprite.play("idle")	
