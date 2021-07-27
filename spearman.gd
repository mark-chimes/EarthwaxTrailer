extends Node2D

const base_offset = -400
const speed_base = 20
export var x_speed = 0.5

export var start_shift = -100

func _ready(): 
	position.x += x_speed * (start_shift + base_offset)

func _process(delta):
	position.x += speed_base * x_speed * delta
