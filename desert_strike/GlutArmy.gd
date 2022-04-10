extends "res://desert_strike/Army.gd"

var Grubling = load("res://desert_strike/creature/Grubling.tscn")

func _ready(): 
	army_dir = State.Dir.LEFT
	initialize_army()
	spawn_first_wave()

func spawn_first_wave(): 
	add_new_creatures(Grubling, NUM_LANES * BANDS_SPAWNED)

func spawn_new_wave(): 
	add_new_creatures(Grubling, NUM_LANES * BANDS_SPAWNED)
