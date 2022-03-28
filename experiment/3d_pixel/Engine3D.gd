extends Node

const HORIZON_ACTUAL = 420 # Where the sky meets land
const HORIZON = HORIZON_ACTUAL - 50 # Where the infinity point is
const SCREEN_MAX_X = 1920
const SCREEN_MAX_Y = 1080
const SCREEN_MID_X = SCREEN_MAX_X / 2
const Z_ORIGIN_Y_OFFSET = SCREEN_MAX_Y - 458 # Where the first layer starts
const HORIZON_HEIGHT = Z_ORIGIN_Y_OFFSET - HORIZON
const X_UNIT =  32.0 # Width in  pixels at z0 to separate
const Z_UNIT = 0.05 # Separation degree for z

var ObjectGenerator3D = preload("res://experiment/3d_pixel/ObjectGenerator3D.gd")
var object_generator = ObjectGenerator3D.new()
var parallax_objects = []
# Player control
const SPEED_MOD = 20
var player_real_pos_x = 0
var player_real_pos_z = 3
enum Dir {
	LEFT = 1,
	RIGHT = -1,
	NONE = 0,
}
var dir = Dir.RIGHT

func _ready():
	dir = Dir.NONE
	object_generator.init_values(self, parallax_objects)

func create_objects_in_rectangle_randoff(object_type, num_x, num_z, x_offset, z_offset, randoff_x,
		x_distance, z_distance, should_randomize, custom_array): 
	object_generator.create_objects_in_rectangle_randoff(object_type, num_x, num_z, x_offset, z_offset,
			randoff_x, x_distance, z_distance, should_randomize, custom_array)
	for object in custom_array:
		object_position_converter(object)

func create_objects_in_rectangle(object_type, num_x, num_z, x_offset, z_offset,
		x_distance, z_distance, should_randomize, custom_array): 
	object_generator.create_objects_in_rectangle(object_type, num_x, num_z, x_offset, z_offset,
			x_distance, z_distance, should_randomize, custom_array)
	for object in custom_array:
		object_position_converter(object)

func create_objects_in_rectangle_back(object_type, num_x, num_z, x_offset, z_offset,
		x_distance, z_distance, should_randomize, custom_array): 
	object_generator.create_objects_in_rectangle(object_type, num_x, num_z, x_offset, z_offset,
			x_distance, z_distance, should_randomize, custom_array)
	for object in custom_array:
		object_position_converter(object)

func _process(delta):
	# hero_world_movement(delta)
	position_stuff_on_screen(delta)

func position_stuff_on_screen(delta): 
	for parallax_obj in parallax_objects:
		parallax_obj.visible = true
		object_position_converter(parallax_obj)

#func hero_world_movement(delta): 
#	if Input.is_action_pressed("ui_right"):
#		dir = Dir.RIGHT
#	elif Input.is_action_pressed("ui_left"):
#		dir = Dir.LEFT
#	else:
#		dir = Dir.NONE
#	var speed_mult = SPEED_MOD
#	if Input.is_action_pressed("run"):
#		speed_mult *= 3
#	player_real_pos_x = player_real_pos_x + (delta * dir * speed_mult)

#func z_scale(parallax_obj):
#	var scale_mult = z_to_size_scale_converter(parallax_obj.real_pos.z)
#	parallax_obj.scale.x = scale_mult
#	parallax_obj.scale.y = scale_mult

#func z_to_size_scale_converter(z_pos): 
#	z_pos = z_pos * Z_UNIT + 1
#	return 1.3/z_pos

#func z_to_y_converter(z_pos):
#	z_pos = z_pos * Z_UNIT + 1
#	return HORIZON + HORIZON_HEIGHT / z_pos

#func z_and_x_to_x_converter(hero_x_pos, z_pos, x_pos):
#	x_pos = (x_pos + hero_x_pos) * X_UNIT * 1.0
#	z_pos = z_pos * Z_UNIT + 1
#	return SCREEN_MID_X + x_pos / z_pos
#

func object_position_converter(object): 
	object.translation.x = object.real_pos.x / 10
	object.translation.y = object.real_pos.y
	object.translation.z = object.real_pos.z / 10
	
	
func add_object_to_parallax_world(object):
	object_position_converter(object)
	parallax_objects.append(object)
