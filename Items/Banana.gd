extends CharacterBody2D

# have an unused, thrown, and sused state

var start_speed = 500
var cur_speed = Vector2(100, 100)
var BANANA_FRICTION = 600
var direction = Vector2(1, 0)
var thrown= false
var pickable = true


# Called when the node enters the scene tree for the first time.
func _ready(): 
	thrown = false

func _physics_process(delta):
	if thrown:
		calculate_speed(delta)
		move_and_slide()			
	else:
		# Not thrown
		pass		
	
func calculate_speed(delta):
	
	#print("Velocity is: " + str(cur_speed) )
	if cur_speed.length() >5:
		cur_speed -= BANANA_FRICTION * cur_speed.normalized() * delta
	else:
		cur_speed = Vector2.ZERO

	set_velocity(cur_speed)
	
func throw(dir):
	direction = dir
	cur_speed = dir*start_speed
	thrown = true
	#print("Direction is: " + str(direction))
	
func destroy():
	queue_free()
