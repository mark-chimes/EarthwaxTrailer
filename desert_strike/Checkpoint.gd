extends "res://parallax/util/ParallaxObject.gd"

# Ownership of 0 means Glut, and 100 means Human.
var MAX_OWNERSHIP = 100
var ownership_level = 50  


func _ready():
	pass
	# modify_ownership(MAX_OWNERSHIP/2)

func _process(delta):
	pass
	#modify_ownership(delta)

func modify_ownership(ownership_increase): 
	ownership_level = ownership_level + ownership_increase
	ownership_level = clamp(ownership_level, 0, MAX_OWNERSHIP)
	var ownership_color = ownership_level*255.0/MAX_OWNERSHIP
	var anti_ownership_color = 255.0 - ownership_color
	var color = Color8(floor(anti_ownership_color), floor(ownership_color), 0, 255)
	$Sprite.modulate = color
	$Label.text = str(floor(ownership_level))
	
# TODO replace this with enum
func set_ownership(ownership_enum): 
	if ownership_enum == -1: 
		ownership_level = 0
	elif ownership_enum == 1: 
		ownership_level = MAX_OWNERSHIP
	else: 
		ownership_level = MAX_OWNERSHIP/2
	modify_ownership(0)
	

# Returns -1 if owned by Glut, 0 if owned by no-one and 1 if owned by human
# TODO replace this with an enum
# TODO maybe use deltas?
func check_ownership(): 
	if ownership_level <= 1: 
		return -1
	elif ownership_level >= MAX_OWNERSHIP-1: 
		return 1
	else: 
		return 0
