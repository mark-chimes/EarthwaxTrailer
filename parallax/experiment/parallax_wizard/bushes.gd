extends Node2D

export var x_speed = 0.3

func _process(delta):
	position.x += x_speed*delta
