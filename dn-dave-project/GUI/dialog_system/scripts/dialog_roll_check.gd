@tool
@icon("res://GUI/dialog_system/icons/answer_bubble.svg")
class_name DialogRollCheck
extends DialogItem

@export var stat_name: String = "charisma"
@export var difficulty: int = 12

@export var success_branch_index: int = 0
@export var failure_branch_index: int = 1

var dialog_branches: Array[DialogBranch] = []

func _ready() -> void:
	super()

	if Engine.is_editor_hint():
		return

	dialog_branches.clear()

	for c in get_children():
		if c is DialogBranch:
			dialog_branches.append(c)

func get_branch_for_result(roll_result: int) -> DialogBranch:
	if dialog_branches.is_empty():
		return null

	if roll_result >= difficulty:
		if success_branch_index >= 0 and success_branch_index < dialog_branches.size():
			return dialog_branches[success_branch_index]
	else:
		if failure_branch_index >= 0 and failure_branch_index < dialog_branches.size():
			return dialog_branches[failure_branch_index]

	return null
