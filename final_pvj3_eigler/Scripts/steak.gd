extends Node2D

@onready var animated_sprite = $AnimatedSprite2D
var life = 20 

func _on_animated_sprite_2d_animation_finished() -> void:
	if(animated_sprite.animation == "Spawn"):
		animated_sprite.play("Spawned")
