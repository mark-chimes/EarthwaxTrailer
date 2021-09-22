extends Node2D

export var x_speed = 0.5

func _process(delta):
	$grassblock.position.x += 8*delta
	$grassblock2.position.x += 16*delta
	$grassblock3.position.x += 20*delta
	$grassblock4.position.x += 22*delta
	$grassblock5.position.x += 26*delta
