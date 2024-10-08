extends Area2D

#Exports
@export var speed = 200
@export var damage = 20

var performer
var angle 
var isInited = false
var toDestroy = false

func init(ang, posX, posY, nameP):
	var sprite = $Sprite2D
	performer = nameP
	angle = ang
	position.x = posX
	position.y = posY
	isInited = true
	sprite.rotation_degrees = rad_to_deg(-ang)


func Destroy():
	queue_free()


func _process(delta: float) -> void:
	if(isInited):
		position.x += cos(angle) * speed * delta
		position.y += sin(-angle) * speed * delta
		

func get_performer():
	return performer


func _on_body_entered(body: Node2D) -> void:
	if(body.name != performer):
		Destroy()
