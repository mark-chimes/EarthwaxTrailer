extends Node2D

signal defeat

var Farmer = preload("res://desert_strike/creature/Farmer.tscn")
onready var parallax_engine = get_parent().get_parent().get_node("ParallaxEngine")
onready var rng = RandomNumberGenerator.new()

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

var dead_farmers = 0
var defeat_threshold = 4

func _ready():
	add_farmer(3)
	add_farmer(7)
	add_farmer(11)
	add_farmer(15)
	state = State.WALK
	for farmer in farmers:
		farmer.set_state(state, Dir.RIGHT)

func get_pos():
	# TODO Optimize this
	# TODO Currently this assumes the army is moving right and is beyond -100
	var front_pos = -100
	for farmer in farmers: 
		if farmer.real_pos.x > front_pos:
			front_pos = farmer.real_pos.x
	return front_pos

func add_farmer(z_pos):
	var farmer = Farmer.instance()
	farmer.set_rng(rng)
	farmers.append(farmer)
	add_child(farmer)
	farmer.real_pos.x = -20 + rng.randi_range(-5, 5)
	farmer.real_pos.z = z_pos
	parallax_engine.add_object_to_parallax_world(farmer)

func fight():
	state = State.FIGHT
	for farmer in farmers:
		farmer.fight(get_pos(), Dir.RIGHT)
		farmer.connect("death", self, "_farmer_death")

#	state = State.DIE
#	for farmer in farmers:
#		farmer.set_state(state, Dir.RIGHT)

func get_state():
	return state
	
func _farmer_death(): 
	dead_farmers += 1
	if dead_farmers >= defeat_threshold: 
		emit_signal("defeat")
		# TODO remove farmers from array
		# TODO Rout
