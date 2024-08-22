extends CharacterBody2D

var player: Node = null
@onready var animated_sprite = $AnimatedSprite2D
var canAttack = false
var isAttacking = false
@export var damage = 10
var pause_or_end = false
@export var life = 100

var is_flashing = false
@export var flash_duration = 0.2

@onready var nav: NavigationAgent2D = $NavigationAgent2D
var moving = true
@export var SPEED = 5000

@export var shader_material_resource : ShaderMaterial
var unique_material : ShaderMaterial

@onready var Steak = load("res://Scenes/steak.tscn")
@export var probability = 30

signal died
@onready var Attack_1 = $Attack_1
@onready var Attack_2 = $Attack_2

func _ready():
	animated_sprite.play("walk")	
	unique_material = shader_material_resource.duplicate() as ShaderMaterial
	animated_sprite.material = unique_material
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
		if (velocity.x < 0):
			animated_sprite.scale.x = -1;
		if (velocity.x > 0):
			animated_sprite.scale.x = 1;			
		move_and_slide()
		if global_position.distance_to(player.position) < 10:
			moving = false
			velocity = Vector2.ZERO


func GetDamage(gdamage):
	if not is_flashing:
		is_flashing = true
		unique_material.set("shader_parameter/damage_flash", 1.0)
		await get_tree().create_timer(flash_duration).timeout
		unique_material.set("shader_parameter/damage_flash", 0.0)
		is_flashing = false
	life -= gdamage
	if(life <= 0):
		emit_signal("died")
		var steak_instance = Steak.instantiate()
		steak_instance.position = position
		var chance = randi() % 100 + 0
		if (chance < probability):
			get_parent().get_parent().get_node("TileMap").add_child(steak_instance)
		queue_free()

func Attack():
	isAttacking = true
	var random_number = randi() % 2 + 1
	if(random_number == 1):
		Attack_1.play()
	else:
		Attack_2.play()
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
	if(animated_sprite.animation == "explode"):
		animated_sprite.visible = false
	if(animated_sprite.animation == "Side_Attack" ||
	animated_sprite.animation == "Up_Attack" ||
	animated_sprite.animation == "Down_Attack"):
		if (canAttack):
			player.GetDamage(damage)
		#animated_sprite.play("Idle")
		animated_sprite.play("walk")
		isAttacking = false


func SET_pause_or_end(state):
	pause_or_end = state

func SET_win(state):
	pause_or_end = state
	animated_sprite.play("explode")
	
func SET_lose(state):
	pause_or_end = state
	animated_sprite.play("celebrate")
