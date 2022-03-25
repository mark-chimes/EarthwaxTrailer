extends "res://parallax/util/ParallaxObject.gd"

var horizontal_speed
var vertical_speed
var vertical_acc 
var rot_dist
var is_flying
var end_x


func _ready(): 
	is_projectile = true

func _process(delta):
	if not is_flying: 
		return
		
	if real_pos.x >= end_x: 
		is_flying = false
		# TODO disappear after timeout
		return
		
	real_pos.x += delta*horizontal_speed
	real_pos.y += delta*vertical_speed
	print("real_pos_y: " + str(real_pos.y))
	vertical_speed += vertical_acc * delta
	var next_frame = floor(real_pos.x / rot_dist)
	get_node("AnimatedSprite").frame = next_frame

