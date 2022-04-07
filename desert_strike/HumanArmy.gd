extends "res://desert_strike/Army.gd"

onready var Archer = load("res://desert_strike/creature/Archer.tscn")
onready var Farmer = load("res://desert_strike/creature/Farmer.tscn")

func _ready(): 
	army_dir = Dir.RIGHT
	initialize_army()
	spawn_first_wave()

func spawn_first_wave(): 
	#add_new_creatures(Farmer, NUM_LANES * BANDS_SPAWNED)
	add_new_creatures(Archer, NUM_LANES * BANDS_SPAWNED * 8)

func spawn_new_wave(): 
	add_new_creatures(Farmer, 2)
	add_new_creatures(Archer, 4)



