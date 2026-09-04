@tool
@icon( "res://GUI/dialog_system/icons/chat_bubbles.svg" )
class_name DialogInteraction extends Area2D

signal player_interacted
signal finished

@export var enabled : bool = true
##●◡●)
@export var task_branch_name : String = ""
@export var game_state_flag_name : String = ""
@export var task_branch_name_2 : String = ""
@export var game_state_flag_name_2 : String = ""
@export var transition_node_path : NodePath
@export var interaction_locked : bool = false
@export var close_dialog_on_branch_match : bool = false
@export var trigger_transition_on_branch_match : bool = false

var dialog_items : Array[ DialogItem ]

@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	area_entered.connect( _on_area_enter )
	area_exited.connect( _on_area_exit )
	
	for c in get_children():
		if c is DialogItem:
			dialog_items.append( c )
	
	pass



func player_interact() -> void:
	if interaction_locked:
		return
	
	if DialogSystem.is_active:
		return

	interaction_locked = true
	player_interacted.emit()

	await get_tree().process_frame
	await get_tree().process_frame
	
	if not DialogSystem.finished.is_connected(_on_dialog_finished):
		DialogSystem.finished.connect(_on_dialog_finished)
	
	if not DialogSystem.branch_selected.is_connected(_on_dialog_branch_selected):
		DialogSystem.branch_selected.connect(_on_dialog_branch_selected)
	
	DialogSystem.show_dialog(dialog_items)
	pass


func _on_area_enter( _a : Area2D) -> void:
	if enabled == false || dialog_items.size() == 0:
		return
	animation_player.play("show")
	PlayerManager.interact_pressed.connect( player_interact )
	pass


func _on_area_exit( _a : Area2D) -> void:
	animation_player.play("hide")
	PlayerManager.interact_pressed.disconnect( player_interact )
	pass

##●◡●)
func _on_dialog_finished() -> void:
	if task_branch_name == "" and game_state_flag_name != "":
		GameState.set_flag(game_state_flag_name)
		print("Set GameState flag on finish:", game_state_flag_name)

	if DialogSystem.finished.is_connected(_on_dialog_finished):
		DialogSystem.finished.disconnect(_on_dialog_finished)
	
	if DialogSystem.branch_selected.is_connected(_on_dialog_branch_selected):
		DialogSystem.branch_selected.disconnect(_on_dialog_branch_selected)

	await _wait_for_interact_release()
	interaction_locked = false
	
	finished.emit()

func _wait_for_interact_release() -> void:
	while Input.is_action_pressed("interact") or Input.is_action_pressed("ui_accept"):
		await get_tree().process_frame

func _get_configuration_warnings() -> PackedStringArray:
	if _check_for_dialog_items() == false:
		return [ "Requires at least one DialogItem node." ]
	else:
		return []



func _check_for_dialog_items() -> bool:
	for c in get_children():
		if c is DialogItem:
			return true
	return false

func _on_dialog_branch_selected(branch : DialogBranch) -> void:
	var matched := false

	if task_branch_name != "" and branch.name == task_branch_name:
		matched = true
		if game_state_flag_name != "":
			GameState.set_flag(game_state_flag_name)
			print("Set GameState flag on branch:", game_state_flag_name)

	if task_branch_name_2 != "" and branch.name == task_branch_name_2:
		matched = true
		if game_state_flag_name_2 != "":
			GameState.set_flag(game_state_flag_name_2)
			print("Set GameState flag on branch:", game_state_flag_name_2)

	if not matched:
		return
	if matched:
		if close_dialog_on_branch_match:
			DialogSystem.hide_dialog()

	if trigger_transition_on_branch_match and transition_node_path != NodePath(""):
		var transition = get_node_or_null(transition_node_path)
		if transition != null and transition.has_method("trigger_transition"):
			print("Triggering transition from branch:", branch.name)
			transition.trigger_transition()
		else:
			print("Transition node missing or invalid:", transition_node_path)

	if close_dialog_on_branch_match:
		await get_tree().process_frame
		DialogSystem.hide_dialog()

	if trigger_transition_on_branch_match:
		var transition = get_node_or_null(transition_node_path)
		if transition != null and transition.has_method("trigger_transition"):
			transition.trigger_transition()
