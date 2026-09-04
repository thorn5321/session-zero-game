extends Node

var score = 0
var score_label = null

func _process(_delta):
	# Find the score label if we haven't yet
	if score_label == null:
		score_label = get_tree().get_first_node_in_group("score_label")

func add_point():
	score += 1
	print("Score:", score)
	update_label()

func update_label():
	if score_label:
		score_label.text = "Score: " + str(score)
