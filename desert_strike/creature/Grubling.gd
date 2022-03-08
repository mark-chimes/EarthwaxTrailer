extends "res://parallax/util/ParallaxObject.gd"

enum Dir {
	LEFT = -1,
	RIGHT = 1,
}

func walk(dir):
	$AnimatedSprite.play("walk")
	$AnimatedSprite.flip_h = (dir == Dir.RIGHT)
