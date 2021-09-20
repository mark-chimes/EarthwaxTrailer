extends Node2D

var FunctionTimerScript = load("res://FunctionTimer.gd")

signal shoot_first_arrow
signal shoot_arrows
signal people_enter
var has_scene_started = false
var timed_functions 
var next_timed_function
var has_ended = false

var function_timer

# Called when the node enters the scene tree for the first time.
func _ready():
	function_timer = FunctionTimerScript.new()
	function_timer.add_function_after(6, funcref(self, 'shoot_first_arrow'))
	function_timer.add_function_after(3, funcref(self, 'shoot_arrows'))
	function_timer.add_function_after(2, funcref(self, 'people_enter'))
	
func start_scene(): 
	has_scene_started = true
	$Rabbits.start_scene()
	$Rat.start_scene()

func shoot_first_arrow(): 
	emit_signal("shoot_first_arrow")

func shoot_arrows(): 
	emit_signal("shoot_arrows")
	
func people_enter(): 
	emit_signal("people_enter")
	
func _process(delta):
	if not has_scene_started or has_ended:
		return
		
	var could_perform_action = function_timer.tick_process(delta)
	has_ended = not could_perform_action

