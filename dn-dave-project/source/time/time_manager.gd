# time_manager.gd
extends Node  # AutoLoad singleton

# Current time, starts at 12
var current_time: int = 12
# Minimum and maximum time
const MIN_TIME: int = 0
const MAX_TIME: int = 12

# Called when the node enters the scene tree
func _ready():
	print("TimeManager ready! Current time:", current_time)

# Decrease time by a certain amount (default 1)
func decrease_time(hours: int = 1):
	current_time = max(current_time - hours, MIN_TIME)
	print("Time decreased! Current time:", current_time)

# Increase time by a certain amount (default 1)
func increase_time(hours: int = 1):
	current_time = min(current_time + hours, MAX_TIME)
	print("Time increased! Current time:", current_time)

# Return the current time
func get_time() -> int:
	return current_time


func _on_button_increase_time_pressed() -> void:
	pass # Replace with function body.
