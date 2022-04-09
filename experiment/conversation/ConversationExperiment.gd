extends Node2D

func _ready():
	display_test_text()
	
func display_test_text(): 
	$Speaker.say("Hello there!")
	yield(get_tree().create_timer(2), "timeout")
	$Speaker.say("Let's wait awhile!")
	yield(get_tree().create_timer(5), "timeout")
	$Speaker.say("Now wait a little time")
	yield(get_tree().create_timer(1), "timeout")
	$Speaker.say("Wait not much")
	yield(get_tree().create_timer(0.5), "timeout")
	$Speaker.say("At all")
	yield(get_tree().create_timer(0.5), "timeout")
	$Speaker.say("The first text...")
	$Speaker.say("...and the second text.")
	yield(get_tree().create_timer(2), "timeout")
	$Speaker.say("A")
	$Speaker.say("Bunch")
	$Speaker.say("of")
	$Speaker.say("text")
	$Speaker.say("at")
	$Speaker.say("once.")	
