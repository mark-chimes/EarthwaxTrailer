extends Node2D

var Grubling = preload("res://desert_strike/creature/Grubling.tscn")

onready var parallax_engine = get_parent().get_parent().get_node("ParallaxEngine")
var grubling
enum Dir {
	LEFT = -1,
	RIGHT = 1,
}

func _ready():
	grubling = Grubling.instance()
	add_child(grubling)
	grubling.real_pos.x = 50
	grubling.real_pos.z = 5
	parallax_engine.add_object_to_parallax_world(grubling)

func _process(delta):
	grubling.walk(Dir.LEFT)
	grubling.real_pos.x -= delta * 10
