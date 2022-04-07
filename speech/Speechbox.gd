extends Node2D

const WPM = 100.0
var WPS = WPM / 60.0
const LPW = 5

var speech_timer = 0
var fade = 1
const FADE_SPEED = 1

var text_queue = []

func _ready():
	pass

func queue_text(text): 
	text_queue.append(text)

func _process(delta): 
	if speech_timer <= 0: 
		if text_queue.empty():
			#$SpeechLabel.text = ""
			if fade > 0: 
				fade -= delta * FADE_SPEED
				modulate = Color(1,1,1,fade)
			else: 
				visible = false
		else: 
			visible = true
			fade = 1
			modulate = Color(1,1,1,1)
			var next_text = text_queue.pop_front()
			$SpeechLabel.text = next_text
			speech_timer = (1+len(next_text)/LPW)/WPS
	else:
		speech_timer -= delta
