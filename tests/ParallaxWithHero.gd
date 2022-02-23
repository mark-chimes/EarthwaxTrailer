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
var DistantForestTile = preload("res://tests/DistantForestTile.tscn")
var Flower = preload("res://plants/Flowers.tscn")
var Grass = preload("res://plants/Grasses.tscn")
var BuildingFront = preload("res://buildings/BuildingFront.tscn")
var BuildingSidesFront = preload("res://buildings/BuildingSidesFront.tscn")
var BuildingSidesFrontLeft = preload("res://buildings/BuildingSidesFrontLeft.tscn")
var BuildingBack = preload("res://buildings/BuildingBack.tscn")
var BuildingBack2 = preload("res://buildings/BuildingBack2.tscn")
var CastleTowersFront = preload("res://buildings/CastleTowersFront.tscn")
var TowerCrenellations = preload("res://buildings/TowerCrenellations.tscn")
var CastleDoors = preload("res://buildings/CastleDoors.tscn")
var CastleMainFront = preload("res://buildings/CastleMainFront.tscn")
var TowerSideRight2 = preload("res://buildings/BuildingBack4.tscn")
var TowerSideRight = preload("res://buildings/tower_side_right.tscn")
var BuildingBackSidewalls = preload("res://buildings/BuildingBackSidewalls.tscn")
var BuildingWheel = preload("res://buildings/BuildingWheel.tscn")
var PosGenerator = preload("res://parallax/RandomPositionGenerator.gd")
var GrassStrip = preload("res://plants/GrassStrip.tscn")
var GrassMud = preload("res://plants/GrassMudStrip.tscn")
var ReedStrip = preload("res://plants/ReedStrip.tscn")
var MudStrip = preload("res://plants/MudStrip.tscn")
var Rat = preload("res://animals/ParallaxRat.tscn")

var ParallaxObjectGenerator = preload("res://parallax/ParallaxObjectGenerator.gd")

var rng = RandomNumberGenerator.new()
var object_generator = ParallaxObjectGenerator.new()

# Generation values
var num_chickens_x = 4
var num_chickens_z = 0#4
var num_spearmen_x = 40
var num_spearmen_z = 8
var spearman_separation = 3

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

var test_wall
var chicken1
var chicken2
	
enum Dir {
	LEFT = 1,
	RIGHT = -1,
	NONE = 0,
}
var dir = Dir.RIGHT
var is_hero_in_row_1 = true

func _ready():
	dir = Dir.NONE
	object_generator.init_values(self, parallax_objects)

#	object_generator.create_objects_in_rectangle(DistantForestTile, num_trees, 1, 
#			-300, 150, 34, 1, false, [])

	create_animals()
	
	object_generator.create_objects_in_rectangle(Spearman, 1, 1, 
		-50, 6, spearman_separation, spearman_separation, 
		false, spearmen)
	

	#LEFT SIDE
#	object_generator.create_objects_in_rectangle(Spearman, 1, 76, 
#			-38, 80, spearman_separation, spearman_separation, 
#			false, spearmen)
#
#	#FRONT	
#	object_generator.create_objects_in_rectangle(Spearman, 76, 1, 
#		-38, 80, spearman_separation, spearman_separation, 
#		false, spearmen)
#
#	#MIDDLE	
#	object_generator.create_objects_in_rectangle(Spearman, 76, 1, 
#		-38, 118, spearman_separation, spearman_separation, 
#		false, spearmen)	
#
#	#RIGHT
#	object_generator.create_objects_in_rectangle(Spearman, 1, 76, 
#		38, 80, spearman_separation, spearman_separation, 
#		false, spearmen)
	
	#BACK
#	object_generator.create_objects_in_rectangle(Spearman, 76, 1, 
#		-38, 156, spearman_separation, spearman_separation, 
#		false, spearmen)
	
	position_hero()
	create_buildings()
	make_reeds()
	generate_lawn() 
#	add_measuring_chickens()
						
	for parallax_obj in parallax_objects:
		parallax_obj.position.y = z_to_y_converter(parallax_obj.real_pos.z)

		parallax_obj.z_index = -parallax_obj.real_pos.z * 10
	
	for spearman in spearmen: 
		z_scale(spearman)
#
func _process(delta):
	hero_world_movement(delta)
	position_stuff_on_screen(delta)

	var wall_sprite = test_wall.get_node("Sprite")
	var width =  z_and_x_to_x_converter(player_real_pos_x, 
				test_wall.real_pos.z+2, test_wall.real_pos.x) - test_wall.position.x
	width = width/3.5
#
	if width < 0: 
		width = 0
				
	wall_sprite.region_rect = Rect2(0,0,width,24)

func make_reeds(): 
	object_generator.create_objects_in_rectangle_randoff(MudStrip, 3, 10, 
			0, -1.5, 0, 120, 0.3, false, reed_strips)	

	object_generator.create_objects_in_rectangle_randoff(ReedStrip, 3, 3, 
			0, -1.8, 0, 120, 0.7, true, reed_strips)	

func create_animals(): 
	object_generator.create_objects_in_rectangle(Chicken, num_chickens_x, num_chickens_z, 
			-num_chickens_x*1.5, 0, 1.5, 1.5, true, chickens)
	
	object_generator.create_single_object(Rat, 1, -1.5, [])
	object_generator.create_single_object(Chicken, -2, 2, [])	

func create_buildings(): 
#	for i in range(10):
#		create_building([BuildingBackSidewalls, BuildingBack, BuildingSidesFront, BuildingFront, BuildingWheel], -300 + 10 + 60*i, 48) 
#	create_building([BuildingBack, BuildingBack2, BuildingBack], 0, 156) 
	create_building2()
	test_wall = BuildingSidesFront.instance()
#	add_child(test_wall)
	test_wall.real_pos.x = 0
	test_wall.real_pos.z = 42
	parallax_objects.push_front(test_wall) # TODO remove			

func position_stuff_on_screen(delta): 
	# print("Player real pos x: " + str(player_real_pos_x))
	for plant in plants:
		plant.position.x = z_and_x_to_x_converter(player_real_pos_x, 
				plant.real_pos.z, plant.real_pos.x)
	for parallax_obj in parallax_objects:
#		Optimization Cone
#		if abs(parallax_obj.real_pos.x + player_real_pos_x) > 4*(20+parallax_obj.real_pos.z):
#			parallax_obj.visible = false
#			continue
		parallax_obj.visible = true
		parallax_obj.position.x = z_and_x_to_x_converter(player_real_pos_x, 
				parallax_obj.real_pos.z, parallax_obj.real_pos.x)

func hero_world_movement(delta): 
	if Input.is_action_pressed("ui_right"):
		dir = Dir.RIGHT
		$Hero/AnimatedSprite.play("walk")
		$Hero/AnimatedSprite.scale.x = -2
		$Hero/Shadow.scale.x = -2
		$HeroReflection/AnimatedSprite.play("walk")
		$HeroReflection/AnimatedSprite.scale.x = -2
		$HeroReflection/Shadow.scale.x = -2
		player_real_pos_x += delta * dir * SPEED_MOD
	elif Input.is_action_pressed("ui_left"):
		dir = Dir.LEFT
		$Hero/AnimatedSprite.play("walk")
		$Hero/AnimatedSprite.scale.x = 2
		$Hero/Shadow.scale.x = 2
		$HeroReflection/AnimatedSprite.play("walk")
		$HeroReflection/AnimatedSprite.scale.x = 2
		$HeroReflection/Shadow.scale.x = 2
		player_real_pos_x += delta * dir * SPEED_MOD
	else:
		dir = Dir.NONE
		$Hero/AnimatedSprite.play("idle")
		$HeroReflection/AnimatedSprite.play("idle")
	# print(player_real_pos_x)
	
	if Input.is_action_just_pressed("ui_up"):
		player_real_pos_z += spearman_separation
		position_hero()
	if Input.is_action_just_pressed("ui_down"):
		player_real_pos_z -= spearman_separation
		position_hero()

	player_real_pos_x = player_real_pos_x + (delta * dir * SPEED_MOD)

func position_hero(): 
	$Hero.position.y = z_to_y_converter(player_real_pos_z)
	$HeroReflection.position.y = z_to_y_converter(player_real_pos_z)
	$Hero.z_index = -player_real_pos_z * 10

func create_building2(): 
	var building = BuildingBack2.instance() 
	building.real_pos.x = 0
	building.real_pos.z = 118
	building.scale.x = 1
	building.scale.y = 1
	add_child(building)
	parallax_objects.push_front(building)
		
	building = CastleMainFront.instance() 
	building.real_pos.x = 0
	building.real_pos.z = 86
	building.scale.x = 1
	building.scale.y = 1
	add_child(building)
	parallax_objects.push_front(building)
			
	building = TowerSideRight.instance() 
	building.real_pos.x = 0
	building.real_pos.z = 84
	building.scale.x = 1
	building.scale.y = 1
	add_child(building)
	parallax_objects.push_front(building)
	
	building = TowerCrenellations.instance() 
	building.real_pos.x = 0
	building.real_pos.z = 81
	building.scale.x = 1
	building.scale.y = 1
	add_child(building)
	parallax_objects.push_front(building)
	
	building = CastleTowersFront.instance() 
	building.real_pos.x = 0
	building.real_pos.z = 80
	building.scale.x = 1
	building.scale.y = 1
	add_child(building)
	parallax_objects.push_front(building)
	
	building = CastleDoors.instance() 
	building.real_pos.x = 0
	building.real_pos.z = 78
	building.scale.x = 1
	building.scale.y = 1
	add_child(building)
	parallax_objects.push_front(building)
	
	
func create_building(building_parts, x, far_z):
	var z = far_z
	var has_scaled = 0
	for Building in building_parts: 
		var building = Building.instance()
		add_child(building)
		if has_scaled == 0:
			building.scale.x = 1
			building.scale.y = 1
#			parallax_objects.push_front(building)
			has_scaled = 1
		elif has_scaled == 1: 
			building.scale.x = 1
			building.scale.y = 1
			has_scaled = 2
			parallax_objects.push_front(building)
		else: 
			building.scale.x = 1
			building.scale.y = 1
			parallax_objects.push_front(building)
		building.real_pos.x = x
		building.real_pos.z = z

		z -= 38

	
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
