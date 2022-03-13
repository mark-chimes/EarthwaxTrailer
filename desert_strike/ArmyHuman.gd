extends Node2D

signal defeat

var Farmer = preload("res://desert_strike/creature/Farmer.tscn")
onready var parallax_engine = get_parent().get_parent().get_node("ParallaxEngine")
onready var rng = RandomNumberGenerator.new()
var frontline_func = null

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
	rng.set_seed(hash("42069"))
	add_farmer(3)
	add_farmer(7)
	add_farmer(11)
	add_farmer(15)
	state = State.WALK
	for farmer in farmers:
		farmer.set_state(state, Dir.RIGHT)
		
func _process(delta): 
	match state:
		State.WALK:
			pass
		State.IDLE:
			pass
		State.FIGHT:
			for i in range(len(farmers)): 
				var farmer = farmers[i]
				if not farmer.state == State.WALK:
					continue
				var grub_pos = frontline_func.call_func(i+1)
				#assume grub is on the right
				if grub_pos - farmer.real_pos.x < 2:
					print("Farmer fighting")
					farmer.set_state(State.FIGHT, Dir.RIGHT)
					farmer.connect("death", self, "_farmer_death")
		State.DIE:
			pass

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
	farmer.real_pos.x = -20 + rng.randi_range(-10, 10)
	farmer.real_pos.z = z_pos
	parallax_engine.add_object_to_parallax_world(farmer)

func fight(new_frontline_func):
	frontline_func = new_frontline_func
	state = State.FIGHT


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

func get_frontline_at_lane(lane_num): 
	# TODO What happens when farmers are removed from the array?
	return farmers[lane_num-1].real_pos.x
	
