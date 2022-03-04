extends Node2D

export var screendist = 10
export var move_speed = 10
export var camera_height = 100000
export var display_height_offset = 0
export var is_drawing_lines = false

func _ready():
	setup_guy($parallax_guy1)
	setup_guy($parallax_guy2)
	setup_guy($parallax_guy3)
	setup_guy($parallax_guy4)
	setup_guy($parallax_guy5)
	setup_guy($parallax_guy6)
	setup_guy($parallax_guy7)
	setup_guy($parallax_guy8)
	setup_guy($parallax_guy9)
	
func setup_guy(the_guy): 
	the_guy.screendist = screendist
	the_guy.move_speed = move_speed
	the_guy.camera_height = camera_height
	the_guy.display_height_offset = display_height_offset
	
func _process(delta):
	update() # REDRAWS THE LINES
	
func _draw():
		draw_line_to_middle($parallax_guy1)
		draw_line_to_middle($parallax_guy2)
		draw_line_to_middle($parallax_guy3)
		draw_line_to_middle($parallax_guy4)
		draw_line_to_middle($parallax_guy5)
		draw_line_to_middle($parallax_guy6)
		draw_line_to_middle($parallax_guy7)
		draw_line_to_middle($parallax_guy8)
		draw_line_to_middle($parallax_guy9)
	
func draw_line_to_middle(the_guy): 
	draw_line(
		Vector2(the_guy.position.x,the_guy.position.y), 
		Vector2(0, display_height_offset), 
		Color(255, 0, 0), 
		1)
