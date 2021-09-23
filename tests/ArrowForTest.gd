extends Node2D

func _ready():
	pass
	
var vert_scale_factor = 0.002
	
var x_speed = 100
var x_start_pos = -1 / (2 * vert_scale_factor) 
var x_pos = x_start_pos
var y_pos = 0

func _process(delta):
	if x_pos < -x_start_pos:
		x_pos += x_speed * delta
		y_pos = vert_scale_factor * x_pos * x_pos
		position.x = x_pos
		position.y = y_pos
		
		rotation = atan(2 * vert_scale_factor * x_pos) - 0.785398
	else: 
		x_pos = -x_start_pos
		y_pos = vert_scale_factor * x_pos * x_pos
		position.x = x_pos
		position.y = y_pos
		print("position.x: " + str(position.x) + ", position.y: " + str(position.y))
