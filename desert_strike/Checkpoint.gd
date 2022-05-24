extends "res://parallax/util/ParallaxObject.gd"

# Ownership of 0 means Glut, and 100 means Human.
var MAX_OWNERSHIP = 100
var ownership = 0  


func _ready():
	modify_ownership(50)

func _process(delta):
	pass
	#modify_ownership(delta)

func modify_ownership(ownership_increase): 
	ownership = ownership + ownership_increase
	ownership = clamp(ownership, 0, MAX_OWNERSHIP)
	var ownership_color = ownership*255.0/MAX_OWNERSHIP
	var anti_ownership_color = 255.0 - ownership_color
	var color = Color8(floor(anti_ownership_color), floor(ownership_color), 0, 255)
	$Sprite.modulate = color
	$Label.text = str(floor(ownership))
	
# Returns -1 if owned by Glut, 0 if owned by no-one and 1 if owned by human
# TODO replace this with an enum
# TODO maybe use deltas?
func check_ownership(): 
	if ownership <= 1: 
		return -1
	elif ownership >= MAX_OWNERSHIP-1: 
		return 1
	else: 
		return 0
