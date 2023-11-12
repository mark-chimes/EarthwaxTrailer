extends Camera2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var camera_speed = 300
var camera_top_pos = 90
var camera_bot_pos = 300
var is_moving_up = false

var camera_target = camera_bot_pos
var old_target = camera_target
var epsilon = 2
# Called when the node enters the scene tree for the first time.
func _ready():
	position.y = camera_target

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_pressed("ui_up") and not is_moving_up:
		is_moving_up = true
		old_target = position.y
		camera_target = camera_top_pos
		print("Old target: " + str(old_target) + " camera_target: " + str(camera_target))
	elif Input.is_action_pressed("ui_down") and is_moving_up:
		is_moving_up = false
		old_target = position.y
		camera_target = camera_bot_pos

	var mod_speed = 0
	
	if abs(position.y - old_target) > abs(position.y - camera_target):
		mod_speed = 80 + 2*abs(position.y - camera_target)
	else: 
		mod_speed = 80 + 2*abs(position.y - old_target)
	
	if is_moving_up:
		if position.y > camera_target + epsilon:
			position.y -= mod_speed*delta
		else: 
			position.y = camera_target
	else:		
		if position.y < camera_target -epsilon:
			position.y += mod_speed*delta
		else: 
			position.y = camera_target


