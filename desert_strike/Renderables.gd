extends Node2D
onready var parallax_engine = $ParallaxEngine

func _on_Simulation_creatures_added_to_world(creatures):
	for creature in creatures:
		creature.parallax_engine = parallax_engine
		parallax_engine.add_object_to_parallax_world(creature)
		creature.connect("disappear", parallax_engine, "_on_object_disappear")
		add_child(creature)
