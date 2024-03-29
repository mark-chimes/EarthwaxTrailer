extends Node2D

const arrow_speed = 500

const movement_back = 500

export var is_upside_down = false

var end_y
var is_shooting = false

func _ready(): 
	var rand_offset = rand_range(0, 100)
	end_y = position.y
	position.x -= movement_back - rand_offset
	if is_upside_down: 
		position.y += movement_back - rand_offset
	else:
		position.y -= movement_back - rand_offset

func _process(delta):
	if is_shooting:
		if is_upside_down: 
			if position.y > end_y:
				position.x += arrow_speed*delta
				position.y -= arrow_speed*delta
			else: 
				is_shooting = false
				embed()
		else:
			if position.y < end_y:
				position.x += arrow_speed*delta
				position.y += arrow_speed*delta
			else: 
				is_shooting = false
				embed()
			
func shoot(): 
	is_shooting = true

func embed(): 
	$arrow.visible = false
	$arrow_embedded.visible = true
