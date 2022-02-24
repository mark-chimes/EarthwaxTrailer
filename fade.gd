extends Sprite
signal half_fade

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
			half_fade()
	else: 
		if alpha > 0: 
			alpha = alpha - delta
			modulate = Color( 0, 0, 0, alpha )
		else:
			alpha = 0
			increase_alpha = true
			stop_fading()

func half_fade(): 
	emit_signal("half_fade")

func set_to_black(): 
	modulate = Color( 0, 0, 0, 1 )
	alpha = 1
	is_fading = false

func fade_from_black(): 
	set_to_black()
	is_fading = true
	
func stop_fading(): 
	is_fading = false

func start_fading(): 
	is_fading = true
