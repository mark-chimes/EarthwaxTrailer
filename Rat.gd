extends Node2D

export var scurry_speed = 20
export var hurry_speed = 50

var is_hurrying = false
var is_left = true
var has_scene_started = false

func _ready():
	pass

func start_scene(): 
	has_scene_started = true

func _process(delta):
	if not has_scene_started: 
		return
	if is_hurrying:
		if is_left:
			position.x -= delta*hurry_speed
		else: 
			position.x += delta*hurry_speed
	else: 
		if is_left:
			position.x -= delta*scurry_speed
		else: 
			position.x += delta*scurry_speed

func start_hurrying(): 
	is_hurrying = true
	$AnimatedSprite.speed_scale *= 2

func go_left(): 
	$AnimatedSprite.flip_h = false
	is_left = true

func go_right(): 
	$AnimatedSprite.flip_h = true
	is_left = false
	
func _on_TimingsController_shoot_arrows():
	start_hurrying()

func _on_TimingsController_people_enter():
	go_right()

