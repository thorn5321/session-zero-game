extends Label

func _ready() -> void:
	update_clock()

	var timer := Timer.new()
	timer.wait_time = 1.0
	timer.autostart = true
	timer.timeout.connect(update_clock)
	add_child(timer)

func update_clock() -> void:
	var datetime := Time.get_datetime_dict_from_system()

	var hour: int = datetime.hour
	var minute: int = datetime.minute
	var second: int = datetime.second

	var period := "AM"
	if hour >= 12:
		period = "PM"

	var display_hour := hour % 12
	if display_hour == 0:
		display_hour = 12

	text = "%02d/%02d/%02d  %d:%02d %s" % [
	datetime.month,
	datetime.day,
	datetime.year % 100,
	display_hour,
	minute,
	period
]
