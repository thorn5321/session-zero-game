extends Node

var flags := {}

func set_flag(flag_name: String, value: bool = true) -> void:
	flags[flag_name] = value

func get_flag(flag_name: String) -> bool:
	return flags.get(flag_name, false)

	GameState.set_flag("rogue_convinced")
	GameState.set_flag("saw_argument")
	GameState.set_flag("end_day_one")
	GameState.set_flag("start_day_two")
	GameState.set_flag("burned")
	GameState.set_flag("talked_blacksmith")
	GameState.set_flag("have_coals")
	GameState.set_flag("dwarf_talk")
	GameState.set_flag("rouge_washed")
	GameState.set_flag("end_day_two")
	GameState.set_flag("end_day_three")
	GameState.set_flag("end_day_four")
	GameState.set_flag("end_day_five")
	GameState.set_flag("end_day_six")
	GameState.set_flag("talked_fighter")
	GameState.set_flag("repeat")
