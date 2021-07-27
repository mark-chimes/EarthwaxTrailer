extends Node2D

export var scurry_speed = 20
export var hurry_speed = 50

var is_hurrying = false

func _ready():
	pass

func _process(delta):
	if is_hurrying:
		position.x -= delta*hurry_speed
	else: 
		position.x -= delta*scurry_speed

func start_hurrying(): 
	is_hurrying = true
	$AnimatedSprite.speed_scale *= 2

func _on_Rabbits_shoot_arrows():
	start_hurrying()
