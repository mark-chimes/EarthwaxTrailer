extends "res://desert_strike/Army.gd"

var Grubling = load("res://desert_strike/creature/Grubling.tscn")

func _ready(): 
	army_dir = Dir.LEFT
	initialize_army()
	spawn_first_wave()
	display_test_text()

func spawn_first_wave(): 
	add_new_creatures(Grubling, NUM_LANES * BANDS_SPAWNED * 2)

func spawn_new_wave(): 
	add_new_creatures(Grubling, 5)

func display_test_text(): 
	yield(get_tree().create_timer(12), "timeout")
	say("Now it's our turn!")
	yield(get_tree().create_timer(2), "timeout")
	say("Wait we're not supposed to be able to speak")
	yield(get_tree().create_timer(5), "timeout")
	say("Grrrrr")
	yield(get_tree().create_timer(1), "timeout")
	say("GHlub")
	yield(get_tree().create_timer(0.5), "timeout")
	say("SSSSSCHHH")
	yield(get_tree().create_timer(0.5), "timeout")
	say("Gleep")
	say("Gloop")
	yield(get_tree().create_timer(2), "timeout")
	say("Kk")
	say("Shtk")
	say("Plk")
	say("Txt")
	say("Nrgle")
	say("Glugh")	
