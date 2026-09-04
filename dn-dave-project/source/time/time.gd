extends Node

# Global time value
var current_time: int = 12
const MAX_TIME := 12
const MIN_TIME := 0

func increase_time(amount: int = 1):
	current_time += amount
	current_time = clamp(current_time, MIN_TIME, MAX_TIME)
	print("Time increased. Current time:", current_time)

func decrease_time(amount: int = 1):
	current_time -= amount
	current_time = clamp(current_time, MIN_TIME, MAX_TIME)
	print("Time decreased. Current time:", current_time)

func get_time():
	return current_time

func reset_time():
	current_time = MAX_TIME
	print("Time reset:", current_time)
