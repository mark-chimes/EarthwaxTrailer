extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var pos_x
# Called when the node enters the scene tree for the first time.
func _ready():
	pos_x = position.x


var timer = 0

func _process(delta):
	timer += delta
	pos_x += 11*delta*4
#	position.x = floor(pos_x)
	position.x = pos_x
#	if timer >= 0.125: 
#		pos_x += 11
#		position.x = floor(pos_x)
#		timer = 0
