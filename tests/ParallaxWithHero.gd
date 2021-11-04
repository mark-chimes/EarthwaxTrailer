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
var Spearman = preload("res://tests/ParallaxMan.tscn")
var Knight = preload("res://tests/ParallaxKnight.tscn")
var Chicken = preload("res://tests/ParallaxChicken.tscn")
# var Grass = preload("res://plants/Grasses.tscn")
var DistantForestTile = preload("res://tests/DistantForestTile.tscn")
var Flower = preload("res://plants/Flowers.tscn")
var BuildingFront = preload("res://buildings/BuildingFront.tscn")
var BuildingBack = preload("res://buildings/BuildingBack.tscn")
var BuildingWheel = preload("res://buildings/BuildingWheel.tscn")
var PosGenerator = preload("res://parallax/RandomPositionGenerator.gd")
var GrassStrip = preload("res://plants/GrassStrip.tscn")
var ReedStrip = preload("res://plants/ReedStrip.tscn")
var MudStrip = preload("res://plants/MudStrip.tscn")

var rng = RandomNumberGenerator.new()

# Generation values
var num_chickens_x = 4
var num_chickens_z = 0#4
var num_spearmen_x = 12
var num_spearmen_z = 8
var spearman_separation = 1.5

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
var spearmen = []
var knights = []
var chickens = []
var grass_strips = []
var reed_strips = []

# Player control
const SPEED_MOD = 5
var player_real_pos_x = 0
var player_real_pos_z = 3

enum Dir {
	LEFT = 1,
	RIGHT = -1,
	NONE = 0,
}
var dir = Dir.RIGHT
var is_hero_in_row_1 = true

func _ready():
	dir = Dir.NONE

	create_objects_in_rectangle(DistantForestTile, num_trees, 1, 
			-300, 150, 34, 1, false, [])

#	create_objects_in_rectangle(Chicken, num_chickens_x, num_chickens_z, 
#			-num_chickens_x*1.5, 0, 1.5, 1.5, true, chickens)
		
	create_objects_in_rectangle(Spearman, num_spearmen_x, num_spearmen_z, 
			0, spearman_separation, spearman_separation, spearman_separation, 
			false, spearmen)
	
	position_hero()
	
	for i in range(10):
		create_building([BuildingBack, BuildingFront, BuildingWheel], -300 + 10 + 60*i, 46) 

	make_reeds()
	generate_lawn() 

						
	for parallax_obj in parallax_objects:
		parallax_obj.position.y = z_to_y_converter(parallax_obj.real_pos.z)
		parallax_obj.z_index = -parallax_obj.real_pos.z * 10

func make_reeds(): 
	create_objects_in_rectangle_randoff(MudStrip, 3, 8, 
			0, -2.5, 0, 120, 0.3, false, reed_strips)	

	create_objects_in_rectangle_randoff(ReedStrip, 3, 3, 
			0, -2.4, 0, 120, 0.7, true, reed_strips)	

#	for z in range(0, 6): 
#		create_objects_in_rectangle_randoff(MudStrip, 3, 1, 
#				0, -1.75 - z/5.0, 0, 128, 0, true, reed_strips)	
#
#	create_objects_in_rectangle_randoff(ReedStrip, 3, 1, 
#			0, -1, 0, 128, 0, true, reed_strips)
#	create_objects_in_rectangle_randoff(ReedStrip, 3, 1, 
#			0, -2, 0, 128, 0, true, reed_strips)
#	create_objects_in_rectangle_randoff(ReedStrip, 3, 1, 
#			0, -3, 0, 128, 0, true, reed_strips)

func _process(delta):
	hero_world_movement(delta)
	position_stuff_on_screen(delta)

func position_stuff_on_screen(delta): 
	for plant in plants:
		plant.position.x = z_and_x_to_x_converter(player_real_pos_x, 
				plant.real_pos.z, plant.real_pos.x)
	for parallax_obj in parallax_objects:
		parallax_obj.position.x = z_and_x_to_x_converter(player_real_pos_x, 
				parallax_obj.real_pos.z, parallax_obj.real_pos.x)

func hero_world_movement(delta): 
	if Input.is_action_pressed("ui_right"):
		dir = Dir.RIGHT
		$HeroParallax/AnimatedSprite.play("walk")
		$HeroParallax/AnimatedSprite.scale.x = -2
		$HeroParallax/Shadow.scale.x = -2
		$HeroParallax2/AnimatedSprite.play("walk")
		$HeroParallax2/AnimatedSprite.scale.x = -2
		$HeroParallax2/Shadow.scale.x = -2
		player_real_pos_x += delta * dir * SPEED_MOD
	elif Input.is_action_pressed("ui_left"):
		dir = Dir.LEFT
		$HeroParallax/AnimatedSprite.play("walk")
		$HeroParallax/AnimatedSprite.scale.x = 2
		$HeroParallax/Shadow.scale.x = 2
		$HeroParallax2/AnimatedSprite.play("walk")
		$HeroParallax2/AnimatedSprite.scale.x = 2
		$HeroParallax2/Shadow.scale.x = 2
		player_real_pos_x += delta * dir * SPEED_MOD
	else:
		dir = Dir.NONE
		$HeroParallax/AnimatedSprite.play("idle")
		$HeroParallax2/AnimatedSprite.play("idle")
	# print(player_real_pos_x)
	
	if Input.is_action_just_pressed("ui_up"):
		player_real_pos_z += spearman_separation
		position_hero()
	if Input.is_action_just_pressed("ui_down"):
		player_real_pos_z -= spearman_separation
		position_hero()

	player_real_pos_x = player_real_pos_x + (delta * dir * SPEED_MOD)

func position_hero(): 
	$HeroParallax.position.y = z_to_y_converter(player_real_pos_z)
	$HeroParallax2.position.y = z_to_y_converter(player_real_pos_z)
	$HeroParallax.z_index = -player_real_pos_z * 10

func create_objects_in_rectangle(object_type, num_x, num_z, x_offset, z_offset,
	x_distance, z_distance, should_randomize, custom_array): 
	for z in range(num_z):
		for x in range(num_x):
			var obj = object_type.instance()
			add_child(obj)
			obj.real_pos.x = x * x_distance + x_offset
			obj.real_pos.z = z * z_distance + z_offset
			if should_randomize: 
				obj.real_pos.x += randf() - 0.5
				obj.real_pos.z += randf() - 0.5
			parallax_objects.append(obj)
			if custom_array != null: 
				custom_array.append(obj)
				
func create_objects_in_rectangle_randoff(object_type, num_x, num_z, x_offset, z_offset, randoff_x,
	x_distance, z_distance, should_randomize, custom_array): 

	for z in range(num_z):
		var x_shift = randf()*randoff_x
		for x in range(num_x):
			var obj = object_type.instance()
			var should_flip = rng.randi_range(0,1)
			if should_flip == 0: 
				obj.scale.x = -obj.scale.x
			add_child(obj)
			obj.real_pos.x = x * x_distance + x_offset
			obj.real_pos.z = z * z_distance + z_offset
			obj.real_pos.x += x_shift
			if should_randomize: 
				obj.real_pos.z += randf() - 0.5
			parallax_objects.append(obj)
			if custom_array != null: 
				custom_array.append(obj)

func create_building(building_parts, x, far_z):
	var z = far_z
	for Building in building_parts: 
		var building = Building.instance()
		add_child(building)
		building.real_pos.x = x
		building.real_pos.z = z
		parallax_objects.push_front(building)
		z -= 2
			
func generate_lawn(): 
	create_objects_in_rectangle_randoff(GrassStrip, 4, 16, 
			-64, 2, 65, 65, 1.5, true, grass_strips)	
	var plants_x_width = 200
	var plants_x_off = -plants_x_width / 2
	var plants_z_off = 3
	var plants_z_length = 16
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
func draw_line_to_middle(phys_obj): 
	draw_line(
		Vector2(phys_obj.position.x,phys_obj.position.y), 
		Vector2(SCREEN_MID_X, HORIZON), 
		Color(255, 0, 0), 
		1)

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
	var num = rng.randi_range(0, 4)
	var plant = Flower.instance()
	plant.plant_num = num

	add_child(plant)
	plant.real_pos.x = x
	plant.real_pos.z = z
	
	if plant.real_pos.z > 20: 
		plant.get_node("AnimatedSprite2").visible = true
		plant.get_node("AnimatedSprite").visible = false
		plant.get_node("AnimatedSprite2").animation = "filtered"
		plant.get_node("AnimatedSprite2").frame = plant.plant_num	
	elif plant.real_pos.z > 15 and plant.real_pos.z <= 20:
		var is_close = rng.randi_range(0,4)
		if is_close == 0:
			plant.get_node("AnimatedSprite").visible = true
			plant.get_node("AnimatedSprite2").visible = false
			plant.get_node("AnimatedSprite").animation = "filtered"
			plant.get_node("AnimatedSprite").frame = plant.plant_num
			plant.get_node("AnimatedSprite").get_node("AnimatedSprite").frame = plant.plant_num
		else: 
			plant.get_node("AnimatedSprite2").visible = true
			plant.get_node("AnimatedSprite").visible = false
			plant.get_node("AnimatedSprite2").animation = "filtered"
			plant.get_node("AnimatedSprite2").frame = plant.plant_num	
	else: 
		plant.get_node("AnimatedSprite").visible = true
		plant.get_node("AnimatedSprite2").visible = false
		plant.get_node("AnimatedSprite").animation = "filtered"
		plant.get_node("AnimatedSprite").frame = plant.plant_num
		plant.get_node("AnimatedSprite").get_node("AnimatedSprite").frame = plant.plant_num
	
	plants.push_front(plant)
