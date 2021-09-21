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
	function_timer.add_function_after(2.0, funcref($Gremlins, 'quiet'))
	function_timer.add_function_after(4.0, funcref(self, 'end_scene'))
		
func _process(delta):
	if has_ended or not has_started: 
		return
		
#	var could_perform_action = function_timer.tick_process(delta)
#	has_ended = not could_perform_action
#
##
#	# TODO  THIS
	timer += delta
	if timer >= 1 and switch == 1:
		$Gremlins.start_gremlins()
		switch = 4
	if timer >= 4 and switch == 4: 
		$FarmerGremlins.huh()
		switch = 5
	if timer >= 5 and switch == 5: 
		$FarmerGremlins.point()
		switch = 7.9
	if timer >= 7.9 and switch == 7.9:
		$FarmerGremlins.attack_prep()
		switch = 8.5
	if timer >= 8.5 and switch == 8.5:
		$FarmerGremlins.scared_cry()
		$FarmerGremlins.attack()
		switch = 10
	if timer >= 10 and switch == 10: 
		$FarmerGremlins.quiet()
		switch = 11.5
	if timer >= 11.5 and switch == 11.5: 
		$FarmerGremlins.announce_run()
		switch = 12
	if timer >= 12 and switch == 12:
		$FarmerGremlins.run_away()
		$Gremlins.chase()
		switch = 14
	if timer >= 14 and switch == 14:
		$FarmerGremlins.quiet()
		switch = 18
	if timer >= 18 and switch == 18:
		switch += 1
		end_scene()

func end_scene(): 
	emit_signal("end_scene")
	# $Gremlins.destroy()

func start_farm_scene(): 
	print(" start_farm_scene")
	timer = -1
	switch = 1
	has_started = true



	

