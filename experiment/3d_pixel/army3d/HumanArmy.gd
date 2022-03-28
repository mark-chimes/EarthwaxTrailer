extends "res://experiment/3d_pixel/army3d/Army.gd"

onready var Archer = load("res://experiment/3d_pixel/creature3d/Archer.tscn")
onready var Farmer = load("res://experiment/3d_pixel/creature3d/Farmer.tscn")

func _ready(): 
	army_dir = Dir.RIGHT
	initialize_army()
	spawn_first_wave()

func spawn_first_wave(): 
	add_new_creatures(Farmer, NUM_LANES * BANDS_SPAWNED * 10)
	add_new_creatures(Archer, NUM_LANES * BANDS_SPAWNED * 10)

func spawn_new_wave(): 
	add_new_creatures(Farmer, 20)
	add_new_creatures(Archer, 40)



