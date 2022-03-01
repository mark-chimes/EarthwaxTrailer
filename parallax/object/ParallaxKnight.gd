extends "res://parallax/util/ParallaxObject.gd"

func _ready(): 
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var random_frame = rng.randi_range(0,50)
	$AnimatedSprite.frame = random_frame
	$AnimatedSprite2.frame = random_frame
	$AnimatedSprite.playing = true
	$AnimatedSprite2.playing = true
