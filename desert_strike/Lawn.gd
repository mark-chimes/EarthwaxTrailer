extends Node2D
const HORIZON_ACTUAL = 420 # Where the sky meets land
const HORIZON = HORIZON_ACTUAL - 50 # Where the infinity point is
const SCREEN_MAX_X = 1920
const SCREEN_MAX_Y = 1080
const SCREEN_MID_X = SCREEN_MAX_X / 2
const Z_ORIGIN_Y_OFFSET = SCREEN_MAX_Y - 458 # Where the first layer starts
const HORIZON_HEIGHT = Z_ORIGIN_Y_OFFSET - HORIZON
const X_UNIT =  32.0 # Width in  pixels at z0 to separate
const Z_UNIT = 0.05 # Separation degree for z

# Imports
var DistantForestTile = preload("res://decor/forest/distant/DistantForestTile.tscn")
var Flower = preload("res://decor/flower/Flower.tscn")
var Grass = preload("res://decor/grass/Grass.tscn")
var PosGenerator = preload("res://parallax/util/RandomPositionGenerator.gd")
var GrassStrip = preload("res://decor/grass/GrassStrip.tscn")
var GrassMud = preload("res://decor/grass/GrassMudStrip.tscn")
var ReedStrip = preload("res://decor/reed/ReedStrip.tscn")
var MudStrip = preload("res://decor/mud/MudStrip.tscn")
var Rat = preload("res://entity/creature/animal/rat/parallax/ParallaxRat.tscn")

var ParallaxObjectGenerator = preload("res://parallax/util/ParallaxObjectGenerator.gd")

var rng = RandomNumberGenerator.new()
var object_generator = ParallaxObjectGenerator.new()

var num_trees = 120
var num_plants_x = 10
var num_plants_z = 10
var plant_x_off = -160 
var plant_z_off = -1
var plant_x_mult = 320
var plant_z_mult = 16

# Parallax Lists
var plants = []
var parallax_objects = []
var grass_strips = []
var reed_strips = []

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
	make_reeds()
	generate_lawn() 
	for parallax_obj in parallax_objects:
		parallax_obj.position.y = z_to_y_converter(parallax_obj.real_pos.z)

		parallax_obj.z_index = -parallax_obj.real_pos.z * 10

func _process(delta):
	hero_world_movement(delta)
	position_stuff_on_screen(delta)

func make_reeds(): 
	object_generator.create_objects_in_rectangle_randoff(MudStrip, 3, 10, 
			0, -1.5, 0, 120, 0.3, false, reed_strips)	

	object_generator.create_objects_in_rectangle_randoff(ReedStrip, 3, 3, 
			0, -1.8, 0, 120, 0.7, true, reed_strips)	

func position_stuff_on_screen(delta): 
	# print("Player real pos x: " + str(player_real_pos_x))
	for plant in plants:
		plant.position.x = z_and_x_to_x_converter(player_real_pos_x, 
				plant.real_pos.z, plant.real_pos.x)
	for parallax_obj in parallax_objects:
		parallax_obj.visible = true
		parallax_obj.position.x = z_and_x_to_x_converter(player_real_pos_x, 
				parallax_obj.real_pos.z, parallax_obj.real_pos.x)

func hero_world_movement(delta): 
	if Input.is_action_pressed("ui_right"):
		dir = Dir.RIGHT
		#player_real_pos_x += delta * dir * SPEED_MOD
	elif Input.is_action_pressed("ui_left"):
		dir = Dir.LEFT
		#player_real_pos_x += delta * dir * SPEED_MOD
	else:
		dir = Dir.NONE
	player_real_pos_x = player_real_pos_x + (delta * dir * SPEED_MOD)

func generate_lawn(): 
	var grass_muds = []
	object_generator.create_objects_in_rectangle(GrassMud, 10, 240, 0, 2, 30, 1, true, grass_muds)
	for grassmud in grass_muds: 
		z_scale(grassmud)
#	create_objects_in_rectangle_randoff(GrassStrip, 4, 16, 
#			-64, 2, 65, 65, 1.5, true, grass_strips)	
	var plants_x_width = 200
	var plants_x_off = -plants_x_width / 2
	var plants_z_off = 3
	var plants_z_length = 32
	var plants_x_sep = 6
	var plants_z_sep = 2
	create_plants(plants_x_off, plants_z_off, 
			plants_x_width, plants_z_length, plants_x_sep, plants_z_sep)

	for plant in plants:
		plant.position.y = z_to_y_converter(plant.real_pos.z)
		plant.z_index = -plant.real_pos.z * 10
	for plant in plants:
		plant.position.x = z_and_x_to_x_converter(player_real_pos_x, 
				plant.real_pos.z, plant.real_pos.x)

func z_scale(parallax_obj):
	var scale_mult = z_to_size_scale_converter(parallax_obj.real_pos.z)
	parallax_obj.scale.x = scale_mult
	parallax_obj.scale.y = scale_mult

func z_to_size_scale_converter(z_pos): 
	z_pos = z_pos * Z_UNIT + 1
	return 1.3/z_pos

func z_to_y_converter(z_pos):
	z_pos = z_pos * Z_UNIT + 1
	return HORIZON + HORIZON_HEIGHT / z_pos

func z_and_x_to_x_converter(hero_x_pos, z_pos, x_pos):
	x_pos = (x_pos + hero_x_pos) * X_UNIT * 1.0
	z_pos = z_pos * Z_UNIT + 1
	return SCREEN_MID_X + x_pos / z_pos
	
func create_plants(x_off, z_off, x_width, z_length, x_sep, z_sep): 
	var positions = PosGenerator.generate_random_positions_sep_wid(
		x_off, z_off, x_width, z_length, x_sep, z_sep)

	for pos in positions: 
		add_random_plant_to_lawn_at(pos[0], pos[1])

func add_random_plant_to_lawn_at(x, z): 
	var num1 = rng.randi_range(0, 4)

	var plant
	if num1 == 0:
		plant = Flower.instance()
		var num = rng.randi_range(0, 4)
		plant.plant_num = num
	else: 
		plant = Grass.instance()
		var num = rng.randi_range(0, 2)
		plant.plant_num = num

	add_child(plant)
	plant.real_pos.x = x
	plant.real_pos.z = z
	
	if plant.real_pos.z > 20: 
		plant.get_node("AnimatedSprite2").visible = true
		plant.get_node("AnimatedSprite").visible = false
		plant.get_node("AnimatedSprite2").animation = "unfiltered"
		plant.get_node("AnimatedSprite2").frame = plant.plant_num	
	elif plant.real_pos.z > 15 and plant.real_pos.z <= 20:
		var is_close = rng.randi_range(0,4)
		if is_close == 0:
			plant.get_node("AnimatedSprite").visible = true
			plant.get_node("AnimatedSprite2").visible = false
			plant.get_node("AnimatedSprite").animation = "unfiltered"
			plant.get_node("AnimatedSprite").frame = plant.plant_num
			plant.get_node("AnimatedSprite").get_node("AnimatedSprite").frame = plant.plant_num
		else: 
			plant.get_node("AnimatedSprite2").visible = true
			plant.get_node("AnimatedSprite").visible = false
			plant.get_node("AnimatedSprite2").animation = "unfiltered"
			plant.get_node("AnimatedSprite2").frame = plant.plant_num	
	else: 
		plant.get_node("AnimatedSprite").visible = true
		plant.get_node("AnimatedSprite2").visible = false
		plant.get_node("AnimatedSprite").animation = "unfiltered"
		plant.get_node("AnimatedSprite").frame = plant.plant_num
		plant.get_node("AnimatedSprite").get_node("AnimatedSprite").frame = plant.plant_num
	
	plants.push_front(plant)
