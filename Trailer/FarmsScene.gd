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
	function_timer.add_function_after(2.0, funcref($Gremlins, 'start_gremlins'))
	function_timer.add_function_after(3.0, funcref($FarmerGremlins, 'huh'))
	function_timer.add_function_after(1.0, funcref($FarmerGremlins, 'point'))
	function_timer.add_function_after(2.9, funcref($FarmerGremlins, 'attack_prep'))
	function_timer.add_function_after(0.6, funcref($FarmerGremlins, 'scared_cry'))
	function_timer.add_function_after(0.0, funcref($FarmerGremlins, 'attack'))
	function_timer.add_function_after(1.5, funcref($FarmerGremlins, 'quiet'))
	function_timer.add_function_after(1.5, funcref($FarmerGremlins, 'announce_run'))
	function_timer.add_function_after(0.5, funcref($FarmerGremlins, 'run_away'))
	function_timer.add_function_after(0.0, funcref($Gremlins, 'chase'))
	function_timer.add_function_after(0.6, funcref($Gremlins, 'second_chase'))
	function_timer.add_function_after(1.4, funcref($FarmerGremlins, 'quiet'))
	function_timer.add_function_after(5.0, funcref(self, 'end_scene'))
		
func _process(delta):
	if has_ended or not has_started: 
		return
		
	var could_perform_action = function_timer.tick_process(delta)
	has_ended = not could_perform_action

func end_scene(): 
	emit_signal("end_scene")
	# $Gremlins.destroy()

func start_farm_scene(): 
	print(" start_farm_scene")
	timer = -1
	switch = 1
	has_started = true



	

