extends Node2D


var horizontal_speed
var vertical_speed
var vertical_acc 
var rot_dist
var is_flying
var end_x

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _process(delta):
	if not is_flying: 
		return
		
	if position.x >= end_x: 
		is_flying = false
		return
		
	position.x += delta*horizontal_speed
	position.y += delta*vertical_speed
	vertical_speed += vertical_acc * delta
	var next_frame = floor(position.x / rot_dist) -2 #TODO
	get_node("AnimatedSprite").frame = next_frame

