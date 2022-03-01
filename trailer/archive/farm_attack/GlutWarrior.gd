extends Node2D

var speed = 50

func _ready():
	pass # Replace with function body.

func _process(delta):
	position.x -= speed * delta
