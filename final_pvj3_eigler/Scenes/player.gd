extends CharacterBody2D

@export var SPEED: float = 200
@onready var animated_sprite = $AnimatedSprite2D

func _physics_process(delta):
	move_character(delta)
	update_animations()

func move_character(delta):
	var input_direction = Input.get_vector("move_left", "move_right", "move_up", "move_bottom")
	velocity = input_direction * SPEED
	move_and_collide(velocity * delta)

func update_animations():
	if velocity.x > 0:
		animated_sprite.scale.x = 1;
		animated_sprite.play("walk")
	if velocity.x < 0:
		animated_sprite.scale.x = -1;		
		animated_sprite.play("walk")
	if velocity.x == 0:
		animated_sprite.play("idle")
