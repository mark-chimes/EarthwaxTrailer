extends Node2D

export var x_speed = 0.5

func _process(delta):
	$grassblock.position.x += 8*delta
	$grassblock2.position.x += 18*delta
	$grassblock3.position.x += 20*delta
	$grassblock4.position.x += 22*delta
	$grassblock5.position.x += 24*delta
	$spekbushes.position.x += 18*delta
	$spekbushes2.position.x += 20*delta
	$spekbushes3.position.x += 22*delta
	$spekbushes4.position.x += 24*delta
