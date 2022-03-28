extends "res://experiment/3d_pixel/army3d/Army.gd"

var Grubling = load("res://experiment/3d_pixel/creature3d/Grubling.tscn")

func _ready(): 
	army_dir = Dir.LEFT
	initialize_army()
	spawn_first_wave()

func spawn_first_wave(): 
	add_new_creatures(Grubling, NUM_LANES * BANDS_SPAWNED * 20)

func spawn_new_wave(): 
	add_new_creatures(Grubling, 50)
