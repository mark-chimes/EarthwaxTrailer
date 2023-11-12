extends Node

# TODO this direction will be affected by what the squad wants to do
var faction_dir = State.Dir.RIGHT

func add_creatures(creatures):
	var marching_squad = SquadMarching.new()
	marching_squad.initialize_army_from_grid(creatures, faction_dir)
	
	# TODO these are just marching squads for now
	# But later they should be defending squads as well   
	pass
