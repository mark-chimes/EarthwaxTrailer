extends Node2D

var screendist = 0
var move_speed = 0
var camera_height = 0
var display_height_offset = -256

export var distance = 10
export var is_debug = false

func _ready():
	scale.x = 100.0/distance
	scale.y = 100.0/distance
	z_index = -distance
	
func _process(delta):
	position.y = display_height_offset + camera_height/distance
	var out_speed = screendist * move_speed / distance
	position.x += delta*out_speed
	if is_debug: 
		print(get_global_position())
