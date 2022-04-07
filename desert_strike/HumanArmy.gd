extends "res://desert_strike/Army.gd"

onready var Archer = load("res://desert_strike/creature/Archer.tscn")
onready var Farmer = load("res://desert_strike/creature/Farmer.tscn")

func _ready(): 
	army_dir = Dir.RIGHT
	initialize_army()
	spawn_first_wave()
	display_test_text()

func spawn_first_wave(): 
	add_new_creatures(Farmer, NUM_LANES * BANDS_SPAWNED)
	add_new_creatures(Archer, NUM_LANES * BANDS_SPAWNED)

func spawn_new_wave(): 
	add_new_creatures(Farmer, 2)
	add_new_creatures(Archer, 4)

func display_test_text(): 
	say("Hello there!")
	yield(get_tree().create_timer(2), "timeout")
	say("Let's wait awhile!")
	yield(get_tree().create_timer(5), "timeout")
	say("Now wait a little time")
	yield(get_tree().create_timer(1), "timeout")
	say("Wait not much")
	yield(get_tree().create_timer(0.5), "timeout")
	say("At all")
	yield(get_tree().create_timer(0.5), "timeout")
	say("The first text...")
	say("...and the second text.")
	yield(get_tree().create_timer(2), "timeout")
	say("A")
	say("Bunch")
	say("of")
	say("text")
	say("at")
	say("once.")	


