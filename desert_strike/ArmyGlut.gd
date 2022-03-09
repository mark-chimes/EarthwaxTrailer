extends Node2D

signal defeat

var Grubling = preload("res://desert_strike/creature/Grubling.tscn")
onready var parallax_engine = get_parent().get_parent().get_node("ParallaxEngine")
onready var rng = RandomNumberGenerator.new()
var frontline_func = null

var grublings = []
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

var dead_grublings = 0
var defeat_threshold = 4

func _ready():
	rng.randomize()
	add_grubling(3)
	add_grubling(7)
	add_grubling(11)
	add_grubling(15)
	state = State.WALK
	for grubling in grublings:
		grubling.set_state(state, Dir.LEFT)
		
func _process(delta): 
	match state:
		State.WALK:
			pass
		State.IDLE:
			pass
		State.FIGHT:
			for i in range(len(grublings)): 
				var grubling = grublings[i]
				if not grubling.state == State.WALK:
					continue
				var farm_pos = frontline_func.call_func(i+1)
				#assume grub is on the right
				if grubling.real_pos.x - farm_pos < 2:
					grubling.set_state(State.FIGHT, Dir.LEFT)
					grubling.connect("death", self, "_grubling_death")
		State.DIE:
			pass

func get_pos():
	# TODO Optimize this
	# TODO Currently this assumes the army is moving left and is before 100
	var front_pos = 100
	for grubling in grublings: 
		if grubling.real_pos.x < front_pos:
			front_pos = grubling.real_pos.x
	return front_pos

func add_grubling(z_pos):
	var grubling = Grubling.instance()
	grubling.set_rng(rng)
	grublings.append(grubling)
	add_child(grubling)
	grubling.real_pos.x = 20 + rng.randi_range(-10, 10)
	grubling.real_pos.z = z_pos
	parallax_engine.add_object_to_parallax_world(grubling)

func fight(new_frontline_func):
	frontline_func = new_frontline_func
	state = State.FIGHT

func get_state():
	return state
	
func _grubling_death(): 
	dead_grublings += 1
	if dead_grublings >= defeat_threshold: 
		emit_signal("defeat")
		# TODO remove grublings from array
		# TODO Rout

func get_frontline_at_lane(lane_num): 
	# TODO What happens when grublings are removed from the array?
	return grublings[lane_num-1].real_pos.x
	

func idle():
	state = State.IDLE
	for grubling in grublings:
		grubling.set_state(state, Dir.LEFT)
