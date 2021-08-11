extends Sprite


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var alpha = 0
var increase_alpha = true
var is_fading = false

# Called when the node enters the scene tree for the first time.
func _ready():
	modulate = Color( 0, 0, 0, 0)
	visible = true

func _process(delta): 
	if not is_fading:
		return
	if increase_alpha:
		if alpha < 1:
			alpha = alpha + delta
			modulate = Color( 0, 0, 0, alpha )
		else: 
			alpha = 1
			increase_alpha = false
	else: 
		if alpha > 0: 
			alpha = alpha - delta
			modulate = Color( 0, 0, 0, alpha )
		else:
			alpha = 0
			increase_alpha = true
			is_fading = false

func start_fading(): 
	is_fading = true
