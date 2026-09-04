extends Node

var current_day: int = 1
var max_time: int = 12
var current_time: int = 12

var trainings_done_today := {}

signal time_changed(current_time: int)
signal day_changed(current_day: int)

func start_new_day() -> void:
	current_day += 1
	current_time = max_time
	trainings_done_today.clear()

	print("New day started:", current_day)
	print("Time reset to:", current_time)

	time_changed.emit(current_time)
	day_changed.emit(current_day)


func decrease_time(hours: int) -> void:
	current_time = max(current_time - hours, 0)

	print("Time decreased by:", hours)
	print("Current time:", current_time)

	time_changed.emit(current_time)


func increase_time(hours: int) -> void:
	current_time = min(current_time + hours, max_time)

	print("Time increased by:", hours)
	print("Current time:", current_time)

	time_changed.emit(current_time)


func has_time() -> bool:
	return current_time > 0


func is_day_over() -> bool:
	return current_time <= 0


func can_train(training_type: String) -> bool:
	return not trainings_done_today.has(training_type)


func mark_training_done(training_type: String) -> void:
	trainings_done_today[training_type] = true
	print("Training done today:", training_type)


func reset_to_day_one() -> void:
	current_day = 1
	current_time = max_time
	trainings_done_today.clear()
	time_changed.emit(current_time)
	day_changed.emit(current_day)
