extends "res://parallax/util/ParallaxObject.gd"
signal attack(this)
signal death(this)
signal creature_positioned(this)
signal done_speaking(this)
signal disappear(this)
signal ready_to_swap(this)
signal swap_with_booking(this, booking_creature)

var State = preload("res://desert_strike/State.gd")

var HealthBar = preload("res://desert_strike/HealthBar.tscn")
var DebugLabel = preload("res://desert_strike/DebugLabel.tscn")
var SpeechBox = preload("res://speech/SpeechBox.tscn")

var parallax_engine

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

var state = State.Creature.IDLE
var sprite_dir = State.Dir.RIGHT
var dir = State.Dir.RIGHT
var is_in_combat = false

var mute = false

var health = 10
onready var health_bar = HealthBar.instance()
var MAX_HEALTH = 10

const WALK_SPEED = 5
const END_POS_DELTA = 0.1
const WALK_TO_OFFSET_MAX = 3

var attack_prep_timer = 0
var time_between_attacks = 3
var time_for_corpse_fade = 3
var walk_target_x
var walk_target_z

var show_health = false
var is_debug_state = false
var is_debug_band_lane = false
var is_debug_target_x = false
var is_debug_static_position = true
onready var debug_label = DebugLabel.instance()
onready var speech_box = SpeechBox.instance()

var is_ready_to_swap = false
var is_booked = false
var is_booking = false
var booking_creature = null

const SWAP_WAIT_TIME = 1
var swap_countdown = 0

func _ready(): 
	rng.randomize()
	priority = rng.randi_range(0,255)
	var color = Color8(255 - priority, priority, 0, 255)
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
		State.Creature.MARCH:
			real_pos.x += delta * WALK_SPEED * dir
		State.Creature.WALK:
			if is_positioned():
				emit_signal("creature_positioned", self)
			elif is_positioned_z():
				real_pos.x += delta * WALK_SPEED * dir
			elif is_positioned_x():
				if walk_target_z < real_pos.z:
					real_pos.z -= delta * WALK_SPEED * 1.5
				else:
					real_pos.z += delta * WALK_SPEED * 1.5
				parallax_engine.update_z_index(self)
			else:
				real_pos.x += delta * WALK_SPEED * dir * 0.6
				if walk_target_z < real_pos.z:
					real_pos.z -= delta * WALK_SPEED
				else:
					real_pos.z += delta * WALK_SPEED
				parallax_engine.update_z_index(self)
				
		State.Creature.AWAIT_FIGHT: 
			pass
		State.Creature.IDLE:
			wait_for_swap(delta)
		State.Creature.FIGHT:
			attack_prep_timer -= delta
			if attack_prep_timer <= 0: 
				do_attack_strike()
				reset_attack_prep_timer()
		State.Creature.DIE:
			pass

func wait_for_swap(delta):
	# TODO this yield is a bit of a hacky way to do it
	if swap_countdown > 0:
		swap_countdown -= delta
		return
	swap_countdown = SWAP_WAIT_TIME + rng.randf_range(-1, 1)
		
#	if not state == State.Creature.IDLE:
#		return
		
	if is_booked: 
		emit_signal("swap_with_booking", self, booking_creature)
		return
		
	is_ready_to_swap = true
	emit_signal("ready_to_swap", self)
	

func book_swap(other_creature): 
	if other_creature.is_booked or other_creature.is_booking: 
		return
	is_ready_to_swap = false
	is_booking = true
	other_creature.get_booked_by(self)
	
func get_booked_by(new_booking_creature): 
	booking_creature = new_booking_creature
	is_booked = true

func is_positioned(): 
	return is_positioned_z() and is_positioned_x()

func is_positioned_z():
	#todo, return 1, 0 or -1
	return abs(walk_target_z - real_pos.z ) < END_POS_DELTA

func is_positioned_x():
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
		State.Creature.MARCH:
			label_text = "march"
		State.Creature.WALK: 
			label_text = "walk"
		State.Creature.AWAIT_FIGHT: 
			label_text = "await"
		State.Creature.FIGHT: 
			label_text = "fight"
		State.Creature.IDLE:
			 label_text = "idle"
		State.Creature.DIE: 	
			label_text = "" # Don't show labels for the dead
	set_debug_label(label_text)

func  set_archery_target_band_lane(band_index, lane_index): 
	ranged_target_band = band_index
	ranged_target_lane = lane_index
	
func set_state(new_state, new_dir):
	update_debug_with_target_x()
	dir = new_dir
	$AnimatedSprite.flip_h = (dir != sprite_dir)
	
	if state == new_state:
		return
		
	if state == State.Creature.FIGHT and new_state != State.Creature.FIGHT: 
		reset_attack_prep_timer()
	
	# This part should be removed when dead creatures no longer get
	# state information from the army
	if state == State.Creature.DIE:
		return
		
	state = new_state

	update_debug_label_with_state()

	match state:
		State.Creature.MARCH:
			$AnimatedSprite.play("walk")
		State.Creature.WALK:
			$AnimatedSprite.play("walk")
		State.Creature.AWAIT_FIGHT:
			$AnimatedSprite.play("idle")
		State.Creature.FIGHT:
			prep_attack()
		State.Creature.IDLE:
			swap_countdown = SWAP_WAIT_TIME + rng.randf_range(-1, 1)
			$AnimatedSprite.play("idle")
		State.Creature.DIE:
			hide_debug()
			hide_health()
			$AnimatedSprite.play("die")
			# $AnimatedSprite.flip_h = (dir != sprite_dir)
			emit_signal("death", self)
			play_sound_death()
			yield($AnimatedSprite, "animation_finished")
			$AnimatedSprite.frame = $AnimatedSprite.frames.get_frame_count("die")
			$AnimatedSprite.playing = false
			yield(get_tree().create_timer(time_for_corpse_fade), "timeout")
			emit_signal("disappear", self)

func take_damage(the_damage): 
	hurt_anim()
	health -= the_damage
#	temporarily removing death to test jostling
#	if health <= 0: 
#		health = 0
#		if state != State.DIE:
#			set_state(State.DIE, dir)
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

func prep_attack(): 
	if is_ranged and band != 0: 
		$AnimatedSprite.play("ranged_attack_prep")
	else:
		$AnimatedSprite.play("attack_prep")
	reset_attack_prep_timer()	

func reset_attack_prep_timer(): 
	attack_prep_timer = time_between_attacks

func do_attack_strike():
	if state == State.Creature.FIGHT: 
		emit_signal("attack", self)
	if state != State.Creature.FIGHT: # has to be checked again after attack signal
		return
	if is_ranged and band != 0: 
		$AnimatedSprite.play("ranged_attack_strike")
		fire_ranged_projectile()
	else:
		$AnimatedSprite.play("attack_strike")
	play_sound_attack()

func fire_ranged_projectile():
	# Overload this
	pass

func hurt_anim(): 
	# TODO we want some hurt effects that go on top of the sprite
	pass
	
func attack_strike_anim_finish(): 
	if state != State.Creature.FIGHT: 
		return
	if is_ranged and band != 0: 
		$AnimatedSprite.play("ranged_attack_prep")
	else:
		$AnimatedSprite.play("attack_prep")

func attack_prep_anim_finish(): 
	if state != State.Creature.FIGHT: 
		return
	if is_ranged and band != 0: 
		$AnimatedSprite.play("ranged_attack_hold")
	else:
		$AnimatedSprite.play("attack_hold")

func attack_anim_finish(): 
	if state != State.Creature.FIGHT: 
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
	if state != State.Creature.FIGHT:
		return
	var sounds = $SoundAttack.get_children()
	sounds[rng.randi() % sounds.size()].play()

func walk_to(new_walk_target_x, new_walk_target_z):
	# TODO happen for other states as well (e.g. fighting)
	is_ready_to_swap = false
	is_booked = false
	is_booking = false
	
	#TODO check we arent in position already
	if is_debug_static_position:
		walk_target_z = new_walk_target_z
		walk_target_x = new_walk_target_x
	else:
		walk_target_z = new_walk_target_z + rng.randf_range(-WALK_TO_OFFSET_MAX, WALK_TO_OFFSET_MAX)
		walk_target_x = new_walk_target_x + rng.randf_range(-WALK_TO_OFFSET_MAX, WALK_TO_OFFSET_MAX)
	update_debug_with_target_x()
	var new_dir
	if walk_target_x > real_pos.x:
		new_dir = State.Dir.RIGHT
	else:
		new_dir = State.Dir.LEFT
	set_state(State.Creature.WALK, new_dir)

func say(text): 
	if state == State.Creature.DIE:
		printerr("Attempting to tell dead creature to say:" + text)
		return
	speech_box.queue_text(text)

func is_speaking(): 
	return speech_box.get_is_speaking()
	
func _on_speech_box_done_speaking(): 
	emit_signal("done_speaking", self)
