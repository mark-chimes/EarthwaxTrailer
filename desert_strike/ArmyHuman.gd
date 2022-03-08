extends Node2D

signal defeat

var Farmer = preload("res://desert_strike/creature/Farmer.tscn")
onready var parallax_engine = get_parent().get_parent().get_node("ParallaxEngine")
var farmer
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
	add_farmer()
	state = State.WALK
	farmer.set_state(state, Dir.RIGHT)

func get_pos():
	return farmer.real_pos.x

func add_farmer():
	farmer = Farmer.instance()
	add_child(farmer)
	farmer.real_pos.x = -20
	farmer.real_pos.z = 5
	parallax_engine.add_object_to_parallax_world(farmer)

func fight():
	state = State.FIGHT
	farmer.set_state(state, Dir.RIGHT)
	yield(get_tree().create_timer(2.0), "timeout")
	emit_signal("defeat")
	state = State.DIE
	farmer.set_state(state, Dir.RIGHT)

func get_state():
	return state
