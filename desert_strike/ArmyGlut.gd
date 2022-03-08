extends Node2D

var Grubling = preload("res://desert_strike/creature/Grubling.tscn")
onready var parallax_engine = get_parent().get_parent().get_node("ParallaxEngine")
var grublings = []
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
	add_grubling(3)
	add_grubling(7)
	add_grubling(11)
	add_grubling(15)
	state = State.WALK
	for grubling in grublings:
		grubling.set_state(state, Dir.LEFT)

func get_pos():
	return grublings[0].real_pos.x

func add_grubling(z_pos):
	var grubling = Grubling.instance()
	grublings.append(grubling)
	add_child(grubling)
	grubling.real_pos.x = 20
	grubling.real_pos.z = z_pos
	parallax_engine.add_object_to_parallax_world(grubling)

func fight():
	state = State.FIGHT
	for grubling in grublings:
		grubling.set_state(state, Dir.LEFT)

func idle():
	state = State.IDLE
	for grubling in grublings:
		grubling.set_state(state, Dir.LEFT)
