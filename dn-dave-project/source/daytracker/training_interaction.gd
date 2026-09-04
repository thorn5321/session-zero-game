extends DialogInteraction

@export var training_type: String = "strength"
@export var stat_to_increase: String = "strength"
@export var amount_to_increase: int = 1

func _on_dialog_finished() -> void:
	if not DayManager.can_train(training_type):
		print("Already trained", training_type)
		return

	PlayerStats.increase_stat(stat_to_increase, amount_to_increase)
	DayManager.mark_training_done(training_type)

	var roll_data = await DiceManager.roll_d20()
	var roll: int = roll_data["total"]

	var time_lost := 0

	if roll >= 16:
		time_lost = 1
	elif roll >= 10:
		time_lost = 2
	else:
		time_lost = 3

	DialogSystem.name_label.text = "Time Check"
	DialogSystem.portrait_sprite.texture = null
	DialogSystem.content.visible_characters = -1
	DialogSystem.content.text = "How long did it take?\nRolled: " + str(roll) + "\nTime passed: " + str(time_lost)

	DialogSystem.dialog_ui.visible = true
	DialogSystem.show_dialog_button_indicator(true)

	await DialogSystem._wait_for_new_interact_press()

	DialogSystem.show_dialog_button_indicator(false)
	DialogSystem.hide_dialog()

	DayManager.decrease_time(time_lost)

	print(stat_to_increase, "increased to:", PlayerStats.get_stat(stat_to_increase))
	print("Rolled:", roll, "| Time lost:", time_lost)
