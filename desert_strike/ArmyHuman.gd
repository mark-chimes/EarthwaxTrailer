extends Node2D

signal defeat

var Farmer = preload("res://desert_strike/creature/Farmer.tscn")
onready var parallax_engine = get_parent().get_parent().get_node("ParallaxEngine")
var farmers = []
enum Dir {
	LEFT = -1,
	RIGHT = 1,
}

enum State {
	WALK,
	FIGHT,
	IDLE,
	DIE,
}

var state = State.IDLE

func _ready():
	add_farmer(3)
	add_farmer(7)
	add_farmer(11)
	add_farmer(15)
	state = State.WALK
	for farmer in farmers:
		farmer.set_state(state, Dir.RIGHT)

func get_pos():
	return farmers[0].real_pos.x

func add_farmer(z_pos):
	var farmer = Farmer.instance()
	farmers.append(farmer)
	add_child(farmer)
	farmer.real_pos.x = -20
	farmer.real_pos.z = z_pos
	parallax_engine.add_object_to_parallax_world(farmer)

func fight():
	state = State.FIGHT
	for farmer in farmers:
		farmer.set_state(state, Dir.RIGHT)
	yield(get_tree().create_timer(5.0), "timeout")
	emit_signal("defeat")
	state = State.DIE
	for farmer in farmers:
		farmer.set_state(state, Dir.RIGHT)

func get_state():
	return state
