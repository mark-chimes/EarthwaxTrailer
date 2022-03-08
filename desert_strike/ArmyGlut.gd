extends Node2D

var Grubling = preload("res://desert_strike/creature/Grubling.tscn")
onready var parallax_engine = get_parent().get_parent().get_node("ParallaxEngine")
var grubling
enum Dir {
	LEFT = -1,
	RIGHT = 1,
}

enum State {
	WALK,
	FIGHT,
	IDLE,
}

var state = State.IDLE

func _ready():
	add_grubling()
	state = State.WALK
	grubling.set_state(state, Dir.LEFT)

func get_pos():
	return grubling.real_pos.x

func add_grubling():
	grubling = Grubling.instance()
	add_child(grubling)
	grubling.real_pos.x = 50
	grubling.real_pos.z = 5
	parallax_engine.add_object_to_parallax_world(grubling)

func fight():
	state = State.FIGHT
	grubling.set_state(state, Dir.LEFT)
