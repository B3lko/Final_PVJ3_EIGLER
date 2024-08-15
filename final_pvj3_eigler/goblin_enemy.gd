extends CharacterBody2D

var player: Node = null
@onready var animated_sprite = $AnimatedSprite2D
var canAttack = false
var isAttacking = false
var damage = 10
var pause_or_end = false
var life = 100

var is_flashing = false
var flash_duration = 0.2

@onready var nav: NavigationAgent2D = $NavigationAgent2D
var moving = true
var SPEED = 10000


func _ready():
	var players = get_tree().get_nodes_in_group("Player")
	if players.size() > 0:
		player = players[0]


func _process(_delta: float) -> void:
	if !pause_or_end:
		if(canAttack && !isAttacking):
			Attack()
		else:
			move(_delta)


func move(delta):
	if moving:
		var direction = Vector3()
		nav.target_position = player.position
		direction = nav.get_next_path_position() - global_position
		direction = direction.normalized()
		
		velocity = velocity.lerp(direction * SPEED * delta, 1 * delta)
		move_and_slide()
		if global_position.distance_to(player.position) < 10:
			moving = false
			velocity = Vector2.ZERO
			print("Stopped")


func GetDamage(gdamage):
	if not is_flashing:
		is_flashing = true
		var material = animated_sprite.material as ShaderMaterial
		material.set("shader_parameter/damage_flash", 1.0)
		await get_tree().create_timer(flash_duration).timeout
		material.set("shader_parameter/damage_flash", 0.0)
		is_flashing = false
	life -= gdamage
	print("Goblin life: " , life)
	if(life <= 0):
		print("goblin is dead")


func Attack():
	isAttacking = true
	var direction = player.global_position - global_position
	if abs(direction.x) > abs(direction.y):
		if direction.x > 0:
			animated_sprite.scale.x = 1;
			animated_sprite.play("Side_Attack")
		else:
			animated_sprite.scale.x = -1;
			animated_sprite.play("Side_Attack")
	else:
		if direction.y > 0:
			animated_sprite.play("Down_Attack")
		else:
			animated_sprite.play("Up_Attack")


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		canAttack = true;


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		canAttack = false;


func _on_animated_sprite_2d_animation_finished() -> void:
	if(animated_sprite.animation == "Side_Attack" ||
	animated_sprite.animation == "Up_Attack" ||
	animated_sprite.animation == "Down_Attack"):
		if (canAttack):
			player.GetDamage(damage)
		animated_sprite.play("Idle")
		isAttacking = false


func SET_pause_or_end(state):
	pause_or_end = state

