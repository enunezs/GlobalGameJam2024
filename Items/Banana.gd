extends RigidBody2D

var picked = false
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _physics_process(delta):
	if picked:
		self.position = get_node("/Marker2D").global_position

func _input(event):
	if Input.is_action_just_pressed("pick_object"):
		if not picked:
			var bodies = $Area2D.get_overlapping_bodies()
			for body in bodies:
				if body.name == "CharacterBody2D" and get_node("../CharacterBody2D").can_pick:
					picked = true
					get_node("../CharacterBody2D").can_pick = false
		else:
			picked = false
			get_node("../CharacterBody2D").can_pick = true
			if get_node("../CharacterBody2D").sprite.flip_h == false:
				apply_impulse(Vector2(), Vector2(90, 0))
			else:
				apply_impulse(Vector2(), Vector2(-90, 0))
		
