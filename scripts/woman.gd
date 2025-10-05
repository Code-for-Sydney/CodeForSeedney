extends CharacterBody2D

# expose var to inspector
@export var move_speed : float = 100
@export var start_direction : Vector2 = Vector2(0, 1)

# set var to AnimationTree node
@onready var animation_tree = $AnimationTree
@onready var state_machine = animation_tree.get("parameters/playback")

var is_walking = false

# initialise
func _ready() -> void:
	#animation_tree.set("parameters/Idle/blend_position", start_direction)
	update_animation_parameters(start_direction)

func _physics_process(_delta: float) -> void:
	# detect movement direction
	var input_direction = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	)
	
	update_animation_parameters(input_direction)
	
	# update velocity
	velocity = input_direction * move_speed
	
	update_state()
	move_and_slide()
	
func update_animation_parameters(input_direction: Vector2):
	# store last input direction for animation
	if(input_direction != Vector2.ZERO):
		animation_tree.set("parameters/Idle/blend_position", input_direction)
		animation_tree.set("parameters/Walk/blend_position", input_direction)
		
func update_state():
	if(velocity != Vector2.ZERO):
		state_machine.travel("Walk")
		if not is_walking:
			$walk_audio.play()
			is_walking = true
	else:
		state_machine.travel("Idle")
		if is_walking:
			$walk_audio.stop()
			is_walking = false
