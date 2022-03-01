extends Node2D

var FunctionTimerScript = load("res://trailer/util/timing/FunctionTimer.gd")

signal end_scene
signal start_fading

var timer = 0
var switch = 0
var has_started = false
var has_ended = false

var function_timer

func _ready(): 
	function_timer = FunctionTimerScript.new()
	$Commander.visible = false
	$Spearman1.visible = false
	$Spearman2.visible = false
	
	function_timer.add_function_after(0, funcref(self, 'people_enter'))
	function_timer.add_function_after(5, funcref($Farmer2, 'begin_walking'))
	function_timer.add_function_after(1, funcref(self, 'commander_admires_land'))
	function_timer.add_function_after(5, funcref(self, 'commander_says_get_to_work'))
	function_timer.add_function_after(5, funcref(self, 'commander_and_spearmen_leave'))
	function_timer.add_function_after(2, funcref(self, 'spearman_leaves'))
	function_timer.add_function_after(4, funcref(self, 'start_fading'))
	function_timer.add_function_after(1, funcref(self, 'end_scene'))
	
#	switch = 16
	# TODO Farmer visibility

func commander_admires_land(): 
	$Farmer1.begin_walking()
	$Commander.say("Ah, these fertile lands will be perfect for our new farms!", 4)
	print("COMMANDER SPEAKS")
	
func commander_says_get_to_work(): 
	$Commander.say("Farmers, get to work!", 3)
	
func commander_and_spearmen_leave(): 
	$Commander.go_left()
	$Commander.begin_walking()
	$Spearman2.go_left()
	$Spearman2.begin_walking()

func spearman_leaves(): 
	$Spearman1.go_left()
	$Spearman1.begin_walking()

func start_fading(): 
	emit_signal("start_fading")

func end_scene(): 
	print("END PEOPLE SCENE")
	emit_signal("end_scene")

func _on_TimingsController_people_enter():
	has_started = true

func _process(delta):
	if has_ended or not has_started: 
		return

	var could_perform_action = function_timer.tick_process(delta)
	has_ended = not could_perform_action
	
func people_enter():
	visible = true
	$Commander.visible = true
	$Commander.begin_walking()
	$Spearman1.begin_walking()
	$Spearman2.begin_walking()
	$Spearman1.visible = true
	$Spearman2.visible = true
