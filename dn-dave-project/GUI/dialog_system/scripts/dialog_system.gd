@tool
@icon("res://GUI/dialog_system/icons/star_bubble.svg")
class_name DialogSystemNode extends CanvasLayer

signal started
signal finished
signal letter_added( letter : String )
##●◡●)
signal branch_selected(branch : DialogBranch)

var is_active : bool = false
var text_in_progress : bool = false
var waiting_for_choice : bool = false
var watching_cutscene : bool = false


var text_speed : float = 0.02
var text_length : int = 0
var plain_text : String

var dialog_items : Array[ DialogItem ]
var dialog_item_index : int = 0


@onready var dialog_ui : Control = $DialogUI
@onready var content: RichTextLabel = $DialogUI/PanelContainer/RichTextLabel
@onready var name_label: Label = $DialogUI/NameLabel
@onready var portrait_sprite: DialogPortrait = $DialogUI/PortraitSprite
@onready var dialog_progress_indicator: PanelContainer = $DialogUI/DialogProgressIndicator
@onready var dialog_progress_indicator_label: Label = $DialogUI/DialogProgressIndicator/Label
@onready var timer: Timer = $DialogUI/Timer
@onready var audio_stream_player: AudioStreamPlayer = $DialogUI/AudioStreamPlayer
@onready var choice_options : VBoxContainer = $DialogUI/VBoxContainer




func _ready() -> void:
	if Engine.is_editor_hint():
		if get_viewport() is Window:
			get_parent().remove_child( self )
			return
		return
	timer.timeout.connect( _on_timer_timeout )
	hide_dialog()
	pass



## Handle key presses, but only if Dialog System is active
func _unhandled_input(event: InputEvent) -> void:
	if is_active == false or watching_cutscene == true:
		return
	if(
			event.is_action_pressed("interact") or
			event.is_action_pressed("ui_accept")
	):
		if text_in_progress == true:
			content.visible_characters = text_length
			timer.stop()
			text_in_progress = false
			show_dialog_button_indicator( true )
			return
		elif waiting_for_choice == true:
			return
		
		advance_dialog()
	pass


func advance_dialog() -> void:
	dialog_item_index += 1
	if dialog_item_index < dialog_items.size():
		start_dialog()
	else:
		hide_dialog()
	pass



## Show the dialog UI
func show_dialog(_items : Array[DialogItem]) -> void:
	is_active = true

	# clear old UI immediately
	name_label.text = ""
	content.text = ""
	content.visible_characters = -1
	portrait_sprite.texture = null
	choice_options.visible = false
	show_dialog_button_indicator(false)

	if _items.size() == 0:
		hide_dialog()
		return

	dialog_items = _items
	dialog_item_index = 0

	if _items[0] is DialogCutscene:
		dialog_ui.visible = false
	else:
		dialog_ui.visible = true

	dialog_ui.process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().paused = true
	await get_tree().process_frame
	started.emit()

	start_dialog()

## Hide Dialog System UI
func hide_dialog() -> void:
	is_active = false
	choice_options.visible = false
	portrait_sprite.texture = null
	name_label.text = ""
	content.text = ""
	dialog_ui.visible = false
	dialog_ui.process_mode = Node.PROCESS_MODE_DISABLED
	get_tree().paused = false
	finished.emit()
	PlayerManager.reset_camera_on_player()



## Initialize UI variables for a new Dialog Interaction
func start_dialog() -> void:
	waiting_for_choice = false
	show_dialog_button_indicator( false )
	var _d : DialogItem = dialog_items[ dialog_item_index ]
	
	if _d is DialogText:
		set_dialog_text( _d as DialogText )
	elif _d is DialogChoice:
		set_dialog_choice( _d as DialogChoice )
	elif _d is DialogRollCheck:
		start_dialog_roll_check( _d as DialogRollCheck )
	elif _d is DialogCutscene:
		start_dialog_cutscene( _d as DialogCutscene  )
	pass

func start_dialog_cutscene( _d : DialogCutscene ) -> void:
	watching_cutscene = true
	_d.play()
	choice_options.visible = false
	dialog_ui.visible = false
	await _d.finished
	watching_cutscene = false
	choice_options.visible = true
	dialog_ui.visible = true
	advance_dialog()
	pass

func start_dialog_roll_check(_d : DialogRollCheck) -> void:
	waiting_for_choice = true
	choice_options.visible = false

	var roll_data = await DiceManager.roll_d20(_d.stat_name)

	var base_roll : int = roll_data["base_roll"]
	var bonus : int = roll_data["bonus"]
	var total : int = roll_data["total"]

	var result_text := "Failure"
	if total >= _d.difficulty:
		result_text = "Success"

	name_label.text = "Check"
	portrait_sprite.texture = null
	content.visible_characters = -1
	content.text = _d.stat_name.capitalize() + " Check\nRolled: " + str(base_roll) + " + " + str(bonus) + " = " + str(total) + "\nNeed: " + str(_d.difficulty) + "\n" + result_text

	show_dialog_button_indicator(true)

	await _wait_for_new_interact_press()

	show_dialog_button_indicator(false)
	waiting_for_choice = false

	var chosen_branch : DialogBranch = _d.get_branch_for_result(total)

	if chosen_branch == null:
		push_warning("DialogRollCheck has no valid branch.")
		advance_dialog()
		return

	branch_selected.emit(chosen_branch)
	show_dialog(chosen_branch.dialog_items)
	pass
	
func _wait_for_new_interact_press() -> void:
	# First wait until the current interact/accept press is released
	while Input.is_action_pressed("interact") or Input.is_action_pressed("ui_accept"):
		await get_tree().process_frame

	# Then wait for a fresh new press
	while true:
		await get_tree().process_frame
		if Input.is_action_just_pressed("interact") or Input.is_action_just_pressed("ui_accept"):
			return

## Set dialog and NPC variables, etc based on dialog item parameters.
## Once set, start text typing timer
func set_dialog_text( _d : DialogText ) -> void:
	content.text = _d.text
	choice_options.visible = false
	name_label.text = _d.npc_info.npc_name
	portrait_sprite.texture = _d.npc_info.portrait
	portrait_sprite.audio_pitch_base = _d.npc_info.dialog_audio_pitch
	content.visible_characters = 0
	text_length = content.get_total_character_count()
	plain_text = content.get_parsed_text()
	text_in_progress = true
	start_timer()
	pass



## Set dialog choice UI based on parameters
func set_dialog_choice( _d : DialogChoice ) -> void:
	choice_options.visible = true
	waiting_for_choice = true
	for c in choice_options.get_children():
		c.queue_free()
	
	for i in _d.dialog_branches.size():
		var _new_choice : Button = Button.new()
		_new_choice.text = _d.dialog_branches[ i ].text
		_new_choice.alignment = HORIZONTAL_ALIGNMENT_LEFT
		_new_choice.pressed.connect( _dialog_choice_selected.bind( _d.dialog_branches[ i ] ) )
		choice_options.add_child( _new_choice )
	
	if Engine.is_editor_hint():
		return
	await get_tree().process_frame
	await get_tree().process_frame

	if choice_options.get_child_count() > 0:
		choice_options.get_child(0).grab_focus()
	pass


func _dialog_choice_selected(_d : DialogBranch) -> void:
	branch_selected.emit(_d)
	choice_options.visible = false

	if not is_active:
		return

	if _d.dialog_items.size() == 0:
		hide_dialog()
		return

	show_dialog(_d.dialog_items)



func _on_timer_timeout() -> void:
	content.visible_characters += 1
	if content.visible_characters <= text_length:
		letter_added.emit( plain_text[ content.visible_characters - 1 ] )
		start_timer()
	else:
		show_dialog_button_indicator( true )
		text_in_progress = false
	pass






## Show dialog NEXT/END indicator once dialog item is complete and ready to advance
func show_dialog_button_indicator( _is_visible : bool ) -> void:
	dialog_progress_indicator.visible = _is_visible
	if dialog_item_index + 1 < dialog_items.size():
		dialog_progress_indicator_label.text = "NEXT"
	else:
		dialog_progress_indicator_label.text = "END"



func start_timer() -> void:
	timer.wait_time = text_speed
	# Manipulate wait_time
	var _char = plain_text[ content.visible_characters - 1 ]
	if '.!?:;'.contains( _char ):
		timer.wait_time *= 4
	elif ', '.contains( _char ):
		timer.wait_time *= 2
	timer.start()
	pass
