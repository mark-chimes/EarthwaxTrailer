extends Node2D

var time_passed = 0
var seconds_between_waves = 10

func _ready():
	pass 
	
func _process(delta):
	time_passed += delta
	if time_passed >= seconds_between_waves:
		time_passed -= seconds_between_waves

	$Hand.set_rotation_degrees(time_passed*360.0/seconds_between_waves)
