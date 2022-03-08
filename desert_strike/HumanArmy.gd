extends Node2D

var Farmer = preload("res://desert_strike/creature/Farmer.tscn")
onready var parallax_engine = get_parent().get_parent().get_node("ParallaxEngine")
var farmer
enum Dir {
	LEFT = -1,
	RIGHT = 1,
}

func _ready():
	farmer = Farmer.instance()
	add_child(farmer)
	farmer.real_pos.x = -50
	farmer.real_pos.z = 5
	parallax_engine.add_object_to_parallax_world(farmer)

func _process(delta):
	farmer.walk(Dir.RIGHT)
	farmer.real_pos.x += delta * 20
	pass
