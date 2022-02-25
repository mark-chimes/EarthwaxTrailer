extends Node2D
signal end_scene

var FunctionTimerScript = load("res://FunctionTimer.gd")
var timer = 0
var switch = 0
var has_started = false
var has_ended = false
var function_timer

func _ready(): 
	function_timer = FunctionTimerScript.new()
	function_timer.add_function_after(0.0, funcref($FarmerGremlins, 'idle_rest'))
	function_timer.add_function_after(0.0, funcref($FarmerGremlins2, 'idle_rest'))
	function_timer.add_function_after(0.0, funcref($FarmerGremlins3, 'idle_rest'))
	function_timer.add_function_after(0.0, funcref($FarmerGremlins4, 'idle_rest'))
	function_timer.add_function_after(2.0, funcref($Gremlins, 'start_gremlins'))
	function_timer.add_function_after(3.0, funcref($FarmerGremlins, 'huh'))
	function_timer.add_function_after(1.0, funcref($FarmerGremlins, 'point'))
	function_timer.add_function_after(0.2, funcref($FarmerGremlins2, 'huh'))
	function_timer.add_function_after(0.1, funcref($FarmerGremlins3, 'huh'))
	function_timer.add_function_after(0.1, funcref($FarmerGremlins4, 'huh'))
	function_timer.add_function_after(0.5, funcref($FarmerGremlins3, 'attack_prep'))
	function_timer.add_function_after(0.2, funcref($FarmerGremlins2, 'attack_prep'))
	function_timer.add_function_after(0.1, funcref($FarmerGremlins4, 'attack_prep'))
	function_timer.add_function_after(0.3, funcref($FarmerGremlins3, 'run_away'))
	function_timer.add_function_after(0.0, funcref($FarmerGremlins2, 'quiet'))
	function_timer.add_function_after(0.0, funcref($FarmerGremlins3, 'quiet'))
	function_timer.add_function_after(0.0, funcref($FarmerGremlins4, 'quiet'))
	function_timer.add_function_after(0.2, funcref($FarmerGremlins2, 'run_away'))
	function_timer.add_function_after(0.2, funcref($FarmerGremlins4, 'run_away'))
	function_timer.add_function_after(1.0, funcref($FarmerGremlins, 'attack_prep'))
	function_timer.add_function_after(0.6, funcref($FarmerGremlins, 'scared_cry'))
	function_timer.add_function_after(0.0, funcref($FarmerGremlins, 'attack'))
	function_timer.add_function_after(1.5, funcref($FarmerGremlins, 'quiet'))
	function_timer.add_function_after(0.5, funcref($Gremlins, 'kill_one'))
	function_timer.add_function_after(1.0, funcref($FarmerGremlins, 'die')) # TODO
	#function_timer.add_function_after(1.5, funcref($FarmerGremlins, 'announce_run'))
	#function_timer.add_function_after(0.5, funcref($FarmerGremlins, 'run_away'))
	function_timer.add_function_after(0.5, funcref(self, 'do_nothing')) # TODO
	function_timer.add_function_after(0.0, funcref($Gremlins, 'chase'))
	function_timer.add_function_after(0.6, funcref($Gremlins, 'second_chase'))
	function_timer.add_function_after(1.4, funcref($FarmerGremlins, 'quiet'))
	function_timer.add_function_after(5.0, funcref(self, 'end_scene'))
		
func _process(delta):
	if has_ended or not has_started: 
		return
		
	var could_perform_action = function_timer.tick_process(delta)
	has_ended = not could_perform_action

func do_nothing(): 
	pass

func end_scene(): 
	emit_signal("end_scene")
	# $Gremlins.destroy()

func start_farm_scene(): 
	print(" start_farm_scene")
	timer = -1
	switch = 1
	has_started = true

