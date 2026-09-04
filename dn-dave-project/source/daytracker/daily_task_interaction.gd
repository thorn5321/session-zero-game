extends DialogInteraction

@export var possible_stat_1: String = "strength"
@export var possible_stat_2: String = "wisdom"
@export var task_id: String = "npc_task"
@export var difficulty: int = 12
@export var success_flag_prefix: String = "helped_"

@export_multiline var success_dialogue: String = "Thank you. That helped a lot."
@export_multiline var failure_dialogue: String = "That did not quite work, but thank you for trying."

@export_multiline var strength_dialogue: String = ""
@export_multiline var wisdom_dialogue: String = ""
@export_multiline var charisma_dialogue: String = ""
@export_multiline var intelligence_dialogue: String = ""
@export_multiline var dexterity_dialogue: String = ""
@export_multiline var constitution_dialogue: String = ""

var chosen_stat: String = ""
var task_running: bool = false

func _ready() -> void:
	super._ready()
	_choose_daily_stat()
	_update_dialog_text()

func _choose_daily_stat() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = DayManager.current_day + task_id.hash()

	chosen_stat = possible_stat_1 if rng.randi_range(0, 1) == 0 else possible_stat_2
	print(task_id, " chose stat today:", chosen_stat)

func _update_dialog_text() -> void:
	var chosen_text := ""

	match chosen_stat:
		"strength":
			chosen_text = strength_dialogue
		"wisdom":
			chosen_text = wisdom_dialogue
		"charisma":
			chosen_text = charisma_dialogue
		"intelligence":
			chosen_text = intelligence_dialogue
		"dexterity":
			chosen_text = dexterity_dialogue
		"constitution":
			chosen_text = constitution_dialogue
		_:
			chosen_text = "Can you help me with something?"

	for item in dialog_items:
		if item is DialogText:
			item.text = chosen_text
			return

func _on_dialog_finished() -> void:
	if task_running:
		return

	task_running = true

	var done_flag := task_id + "_done_day_" + str(DayManager.current_day)

	if GameState.get_flag(done_flag):
		print("Already helped this NPC today.")
		task_running = false
		return

	print("Rolling task stat:", chosen_stat)

	var task_roll_data = await DiceManager.roll_d20(chosen_stat)
	var task_total: int = task_roll_data["total"]
	var passed := task_total >= difficulty

	await show_task_message(
		chosen_stat.capitalize() + " Check\n" +
		"Rolled: " + str(task_total) + "\n" +
		"Need: " + str(difficulty)
	)

	print("Rolling time check")

	var time_roll_data = await DiceManager.roll_d20()
	var time_roll: int = time_roll_data["total"]

	var time_lost := 0

	if time_roll >= 16:
		time_lost = 1
	elif time_roll >= 10:
		time_lost = 2
	else:
		time_lost = 3

	DayManager.decrease_time(time_lost)

	await show_task_message(
		"Time Check\n" +
		"Rolled: " + str(time_roll) + "\n" +
		"Time passed: " + str(time_lost)
	)

	var final_text := failure_dialogue

	if passed:
		GameState.set_flag(success_flag_prefix + task_id)
		final_text = success_dialogue
		print("Task success:", success_flag_prefix + task_id)
	else:
		print("Task failed.")

	await show_task_message(final_text)

	DialogSystem.hide_dialog()
	GameState.set_flag(done_flag)

	task_running = false

func show_task_message(text: String) -> void:
	DialogSystem.dialog_ui.visible = true
	DialogSystem.dialog_ui.process_mode = Node.PROCESS_MODE_ALWAYS
	DialogSystem.name_label.text = "Check"
	DialogSystem.portrait_sprite.texture = null
	DialogSystem.content.visible_characters = -1
	DialogSystem.content.text = text
	DialogSystem.show_dialog_button_indicator(true)

	await DialogSystem._wait_for_new_interact_press()

	DialogSystem.show_dialog_button_indicator(false)
