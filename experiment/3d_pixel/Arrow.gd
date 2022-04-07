extends "res://experiment/3d_pixel/Object3D.gd"

var horizontal_speed
var vertical_speed
var vertical_acc 
var rot_dist
var is_flying
var end_x
var start_x

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
	vertical_speed += vertical_acc * delta
	
	# uncomment the next line for SPIN
	# rotation_degrees.z = -90 * (real_pos.x - start_x) / rot_dist
	rotation_degrees.z = -90*(real_pos.x - start_x)/(end_x - start_x)
	
	
	# var next_frame = floor((real_pos.x - start_x) / rot_dist)
	# get_node("AnimatedSprite").frame = next_frame

