extends Label

@onready var ENEMY_HIT = $laugh_sound


var score = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_enemy_squashed():
	score += 1
	text = "Score: %s" % score
	ENEMY_HIT.play()

	# play sound effect

# Called every frame. 'delta' is the elapsed time since the previous frame.
