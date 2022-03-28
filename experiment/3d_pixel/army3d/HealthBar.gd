extends Spatial

var health

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func init_health_bar(max_health): 
	update_health(max_health)
	$ProgressBar.max_value = max_health
	
func update_health(new_health): 
	health = new_health
	$ProgressBar.value = health
	
func set_color(color_scheme: Color):
	var style_box = $ProgressBar.get("custom_styles/fg")
	style_box.bg_color = color_scheme # Color8(r, g, b, a)
