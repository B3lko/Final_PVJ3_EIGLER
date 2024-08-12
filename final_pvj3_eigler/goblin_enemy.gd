extends CharacterBody2D

var player: Node = null
@onready var animated_sprite = $AnimatedSprite2D
var canAttack = false
var isAttacking = false
var damage = 10

func _ready():
	var players = get_tree().get_nodes_in_group("Player")
	if players.size() > 0:
		player = players[0]


func _process(delta: float) -> void:
	if(canAttack && !isAttacking):
		Attack()


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
