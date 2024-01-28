extends CharacterBody2D
# This is the base class for all characters in the game.

# Base states
enum State {IDLE, MOVE, CARRYING, THROWING, STUNNED, DEAD, SPAWN}
# TODO Removed for now. Will add back in later
#PICKING_UP

# Declare member variables here. Break down per state
# IDLE

# MOVE
@export var FRICTION = 500
@export var MAX_SPEED = 300
@export var ACCELERATION = 1500
@onready var MOVE_SOUND = $steps

# PICKING_UP
# Get position of 

# CARRYING
# Get marker for obejct position
@onready var object_holder = get_node("ItemPosMarker")

# THROWING
@onready var axis = Vector2.ZERO

# DEAD
signal hit

# STUNNED
@export var stunned_time: float = 2.0
@export var stun_velocity: float = 1500.0
#var stun_decay = 0.5

# Member variables
@export var _current_time: float = 0.0
@export var _target_time: float = 0.0

var state_transition : bool = true # is state transitioning
var state = State.MOVE # start state
var item = null # item being carried
var item_holding = false # is player item_holding an item
var direction = Vector2() # direction to player
var last_mouse_pos = Vector2.RIGHT # last mouse position
var hit_direction

@onready var animated_sprite = $AnimatedSprite2D
@onready var animation_player = $AnimatedSprite2D/AnimationPlayer


# Called when the node enters the scene tree for the first time.
func _ready(): 	

	# log error if not found
	if object_holder == null:
		print("Player not found")
		return
	if animated_sprite == null:
		print("Animation player not found")
		return

	state = State.SPAWN
	state_transition = true


func _physics_process(delta):
	# print enemy state in text
	#print("State: " + str(state))
	
	_current_time += delta

	#print current and target time
	#print("Current time: " + str(_current_time))
	#print("Target time: " + str(_target_time))

	match state:

		State.SPAWN:
			spawn()

		State.MOVE:
			move(delta)

		State.CARRYING:
			pick_up()

		State.THROWING:
			throwing()
		State.STUNNED:
			stunned(delta)
		State.DEAD:
			die()

	# update animation

	
### State: SPAWN
func spawn():
	if state_transition:
		state_transition = false
		
		# get animation duration
		_target_time = animation_player.get_animation("Spawn").length
		_current_time = 0.0
		#animation_player.
	
		# Play drop in animation
		animation_player.play("Spawn")

		

	if _target_time < _current_time:
		state = State.MOVE
		state_transition = true


### State: MOVE
func move(delta):
	if state_transition:
		state_transition = false
		velocity = Vector2.ZERO
		_target_time = 0.0
		_current_time = 0.0
		#animation_player.
		animation_player.play("Run")
		
	
	axis = get_input_axis()
	if axis == Vector2.ZERO:
		apply_friction(FRICTION * delta)
		
	else:
		apply_movement(axis * ACCELERATION * delta)
		
	move_and_slide()


	# Animations
	if velocity.x != 0:
		animated_sprite.flip_h = velocity.x < 0

	if item_holding:
		animated_sprite.play("Hold")
	elif velocity.length() < 1.0 :
		animated_sprite.play("Idle")
		animation_player.play("Idle")

	else:
		animated_sprite.play("Run")


func get_input_axis():

	axis.x = int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left"))
	axis.y = int(Input.is_action_pressed("move_down")) - int(Input.is_action_pressed("move_up"))	
		
	return axis.normalized()

func apply_friction(amount):
	if velocity.length() > amount:
		velocity -= velocity.normalized() * amount
	else:
		velocity = Vector2.ZERO

func apply_movement(accel):
	velocity += accel
	velocity = velocity.limit_length(MAX_SPEED)

### State: CARRYING
func pick_up():

	state_transition = false


	# set item as child of object holder
	item_holding = true
	var old_transform = item.global_transform
	item.get_parent().remove_child(item)
	add_child(item)
	item.global_transform = old_transform
	# set item as kinematic
	# set item position to object holder position
	item.position = object_holder.position
	#item.set_physics_process(false)
	state = State.MOVE
	
func throwing():
	state_transition = false

	#print("Throwing") 
	item_holding = false
	# Disown the child
	# Unparent item, preserve position 
	
	var old_transform = item.global_transform
	remove_child(item)
	get_parent().add_child(item)
	item.global_transform = old_transform

	# throw item
	# set item as not kinematic
	# set item velocity to direction
	item.set_physics_process(true)

	# add force
	direction = (last_mouse_pos - item.get_global_position()).normalized()
	item.throw(direction)

	item = null


	state = State.MOVE
	pass # Replace with function body.

func drop_item():
	state_transition = false

	#print("Throwing") 
	item_holding = false

	
	var old_transform = item.global_transform
	remove_child(item)
	get_parent().add_child(item)
	item.global_transform = old_transform

	# throw item
	# set item as not kinematic
	# set item velocity to direction
	item.set_physics_process(true)

	# add force
	direction = (last_mouse_pos - get_global_position()).normalized()
	item.drop(direction)

	item = null


	state = State.MOVE

	pass # Replace with function body.

func stunned(delta):
	# transition IN
	if state_transition:
		state_transition = false
		_target_time = stunned_time
		_current_time = 0.0


		animated_sprite.play("Slide")

		if item_holding:
			drop_item()


	var percent = _current_time / _target_time

	# Apply stun velocity, slow down with time
	velocity = hit_direction * stun_velocity * (1.0 - percent)
	move_and_slide()
	#global_position += velocity * delta	

	# transition OUT
	if _target_time < _current_time:
		state = State.MOVE
		state_transition = true
	
func die():
	hit.emit()
	queue_free()

func update_animation():
	# flip sprite
	pass

### External signals
# Check for items
func _on_area_2d_area_entered(area):
	#print("Area name: " + area.get_parent().name)
	# if area is an item
	if area.get_parent().is_in_group("Item") and state == State.MOVE and not area.get_parent().thrown and not item_holding:
		# set state to carrying
		
		state = State.CARRYING
		item = area.get_parent()
	

func _on_area_2d_area_exited(area):
	if area.is_in_group("Scenario") and not state == State.SPAWN:
		state = State.DEAD
		
# Check for enemies
func _on_area_2d_body_entered(body):
	# if body is an enemy
	#print("Body name: " + str(body.is_in_group("Enemy")))
	if body.is_in_group("Enemy") and not state == State.STUNNED:
		state = State.STUNNED
		hit_direction = (get_global_position()- body.get_global_position()).normalized()
		state_transition = true
		body.player_hit(hit_direction)		
			

# on click
func _input(event):
	# Mouse in viewport coordinates.
	if event is InputEventMouseButton:
		last_mouse_pos = event.position
		#print("Mouse Click/Unclick at: ", event.position)
		if event.is_pressed():
			#print("Mouse Clicked")
			# if player is carrying an item
			if item_holding:
				state = State.THROWING


