extends "res://parallax/util/ParallaxObject.gd"
signal attack(this)
signal death(this)
signal creature_positioned(this)
signal done_speaking(this)
signal disappear(this)
signal ready_to_swap(this)

var HealthBar = preload("res://desert_strike/HealthBar.tscn")
var DebugLabel = preload("res://desert_strike/DebugLabel.tscn")
var SpeechBox = preload("res://speech/SpeechBox.tscn")

onready var rng = RandomNumberGenerator.new()
var melee_damage
var ranged_damage

var is_ranged = false # TODO 
var attack_range = 0
var ranged_target_band
var ranged_target_lane

var band
var lane
var priority = 0

enum Dir {
	LEFT = -1,
	RIGHT = 1,
}

enum State {
	MARCH,
	WALK,
	AWAIT_FIGHT,
	FIGHT,
	IDLE,
	DIE,
}

var state = State.IDLE
var sprite_dir = Dir.RIGHT
var dir = Dir.RIGHT
var is_in_combat = false
var is_ready_to_swap = false
var mute = true

var health = 10
onready var health_bar = HealthBar.instance()
var MAX_HEALTH = 10

const WALK_SPEED = 5
const END_POS_DELTA = 0.1

var time_between_attacks = 3
var time_for_corpse_fade = 3
var walk_target_x

var show_health = false
var is_debug_state = false
var is_debug_band_lane = false
var is_debug_target_x = false
var is_speech_possible = true
onready var debug_label = DebugLabel.instance()
onready var speech_box = SpeechBox.instance()

func _ready(): 
	rng.randomize()
	priority = rng.randi_range(0,255)
	var color = Color8(priority, 255 - priority, 0, 255)
	$AnimatedSprite.modulate = color
	init_health_bar()
	add_child(debug_label)
	add_child(speech_box)
	speech_box.connect("done_speaking", self, "_on_speech_box_done_speaking")
	debug_label.position.x = 0
	debug_label.position.y = -96
	update_debug_with_target_x()
	update_debug_label_with_state()
	update_debug_with_band_lane()
	$AnimatedSprite.connect("animation_finished", self, "_on_animation_finished")

func set_band_lane(new_band, new_lane): 
	band = new_band
	lane = new_lane
	update_debug_with_band_lane()

func set_band(new_band): 
	set_band_lane(new_band, lane)
	
func set_lane(new_lane): 
	set_band_lane(band, new_lane)
	
func init_health_bar(): 
	add_child(health_bar)
	health_bar.init_health_bar(MAX_HEALTH)
	if not show_health: 
		health_bar.visible = false
		
func hide_health(): 
	show_health = false
	health_bar.visible = false

func update_health_bar(new_health): 
	health_bar.update_health(new_health)

func _process(delta):
	match state:
		State.MARCH:
			real_pos.x += delta * WALK_SPEED * dir
		State.WALK:
			if is_positioned():
				emit_signal("creature_positioned", self)
				wait_for_swap()
				return
			real_pos.x += delta * WALK_SPEED * dir
		State.AWAIT_FIGHT: 
			pass
		State.IDLE:
			pass
		State.FIGHT:
			pass
		State.DIE:
			pass

func wait_for_swap():
	yield(get_tree().create_timer(3), "timeout")
	if not state == State.IDLE:
		return
	emit_signal("ready_to_swap", self)
	is_ready_to_swap = true
	wait_for_swap()

func is_positioned(): 
	return abs(walk_target_x - real_pos.x ) < END_POS_DELTA
	
func hide_debug(): 
	debug_label.visible = false

func set_debug_label(label_text): 
	if debug_label != null:
		debug_label.get_node("Label").text = label_text
	
func update_debug_with_band_lane(): 
	if not is_debug_band_lane: 
		return 
	set_debug_label(str(band))# + ", " + str(lane))

func update_debug_with_target_x(): 
	if not is_debug_target_x: 
		return 
	if walk_target_x == null: 
		return
	var decimaled_float = stepify(walk_target_x, 0.01)	
	set_debug_label(str(decimaled_float))

func update_debug_label_with_state(): 
	if not is_debug_state: 
		return 
	
	var label_text
	match state:
		State.MARCH:
			label_text = "march"
		State.WALK: 
			label_text = "walk"
		State.AWAIT_FIGHT: 
			label_text = "await"
		State.FIGHT: 
			label_text = "fight"
		State.IDLE:
			 label_text = "idle"
		State.DIE: 	
			label_text = "" # Don't show labels for the dead
	set_debug_label(label_text)

func  set_archery_target_band_lane(band_index, lane_index): 
	ranged_target_band = band_index
	ranged_target_lane = lane_index
	
func set_state(new_state, new_dir):
	# This part is temporary. Should be removed when dead creatures no longer get
	# state information from the army
	if state == State.DIE and (new_state in [State.WALK, State.AWAIT_FIGHT, State.FIGHT, State.IDLE]):
		return
	state = new_state
	
	update_debug_label_with_state()
	update_debug_with_target_x()
	dir = new_dir
	match state:
		State.MARCH:
			$AnimatedSprite.play("walk")
		State.WALK:
			$AnimatedSprite.play("walk")
		State.AWAIT_FIGHT:
			$AnimatedSprite.play("idle")
		State.FIGHT:
			if is_ranged and band != 0: 
				$AnimatedSprite.play("ranged_attack_prep")
			else:
				$AnimatedSprite.play("attack_prep")
			prepare_attack_strike()
		State.IDLE:
			$AnimatedSprite.play("idle")
		State.DIE:
			hide_debug()
			hide_health()
			$AnimatedSprite.play("die")
			$AnimatedSprite.flip_h = (dir != sprite_dir)
			emit_signal("death", self)
			play_sound_death()
			yield($AnimatedSprite, "animation_finished")
			$AnimatedSprite.frame = $AnimatedSprite.frames.get_frame_count("die")
			$AnimatedSprite.playing = false
			yield(get_tree().create_timer(time_for_corpse_fade), "timeout")
			emit_signal("disappear", self)
			
	$AnimatedSprite.flip_h = (dir != sprite_dir)

func take_damage(the_damage): 
	hurt_anim()
	health -= the_damage
	if health <= 0: 
		health = 0
		if state != State.DIE:
			set_state(State.DIE, dir)
	update_health_bar(health)

func _on_animation_finished():
	match $AnimatedSprite.get_animation():
		"ranged_attack_strike":
			attack_strike_anim_finish()
		"attack_strike":
			attack_strike_anim_finish()
		"ranged_attack_hold":
			pass
		"attack_hold": 
			pass
		"ranged_attack_prep":
			attack_prep_anim_finish()
		"attack_prep":
			attack_prep_anim_finish()

func prepare_attack_strike(): 
	yield(get_tree().create_timer(time_between_attacks), "timeout")
	# TODO needs to cancel this - we need to fix how fighting works
	if state == State.FIGHT: 
		emit_signal("attack", self)
	if state != State.FIGHT: # has to be checked again after attack signal
		return
	if is_ranged and band != 0: 
		$AnimatedSprite.play("ranged_attack_strike")
		fire_ranged_projectile()
	else:
		$AnimatedSprite.play("attack_strike")
	play_sound_attack()
	prepare_attack_strike()

func fire_ranged_projectile():
	# Overload this
	pass

func hurt_anim(): 
	# TODO we want some hurt effects that go on top of the sprite
	pass
	
func attack_strike_anim_finish(): 
	if state != State.FIGHT: 
		return
	if is_ranged and band != 0: 
		$AnimatedSprite.play("ranged_attack_prep")
	else:
		$AnimatedSprite.play("attack_prep")

func attack_prep_anim_finish(): 
	if state != State.FIGHT: 
		return
	if is_ranged and band != 0: 
		$AnimatedSprite.play("ranged_attack_hold")
	else:
		$AnimatedSprite.play("attack_hold")

func attack_anim_finish(): 
	if state != State.FIGHT: 
		return
	if is_ranged and band != 0: 
		$AnimatedSprite.play("ranged_attack_prep")
	else: 
		$AnimatedSprite.play("attack_prep")
		
func play_sound_death():
	if mute: 
		return
	var sounds = $SoundDie.get_children()
	sounds[rng.randi() % sounds.size()].play()

func play_sound_attack():
	if mute: 
		return
	if state != State.FIGHT:
		return
	var sounds = $SoundAttack.get_children()
	sounds[rng.randi() % sounds.size()].play()

func walk_to(new_walk_target_x):
	#TODO check we arent in position already
	is_ready_to_swap = false
	walk_target_x = new_walk_target_x
	var new_dir
	if new_walk_target_x > real_pos.x:
		new_dir = Dir.RIGHT
	else:
		new_dir = Dir.LEFT
	set_state(State.WALK, new_dir)

func say(text): 
	if state == State.DIE:
		printerr("Attempting to tell dead creature to say:" + text)
		return
	speech_box.queue_text(text)

func is_speaking(): 
	return speech_box.is_speaking()
	
func _on_speech_box_done_speaking(): 
	emit_signal("done_speaking", self)
