extends Control

var hits = 0
var amount_per_click = 1
var finished = false

@export var music : AudioStream
@export var hits_to_complete: int = 10
@export_file("*.tscn") var next_scene_path: String
@export var target_transition_area: String = "LevelTransition"
@export var success_sound: AudioStream
@export_file("*.tscn") var alternate_next_scene_path: String
@export var required_flag_name: String = ""
@export var alternate_target_transition_area: String = ""
@export_file("*.tscn") var second_alternate_next_scene_path: String
@export var second_required_flag_name: String = ""
@export var second_alternate_target_transition_area: String = ""

signal hits_changed
signal hits_clicked
signal minigame_completed

@onready var hammer_audio: AudioStreamPlayer = get_node_or_null("CanvasLayer/HammerAudio")
@onready var success_audio: AudioStreamPlayer = get_node_or_null("CanvasLayer/SuccessAudio")
@onready var complete_label = get_node_or_null("CanvasLayer/CompleteLabel")
@onready var click_button = get_node_or_null("CanvasLayer/LeftPanel/BlacksmithBackground/Background/MarginContainer/Stats/CenterContainer/ClickButton")
@onready var level_transition = get_node_or_null("LevelTransitionBSM2")
@onready var fade_transition = get_node_or_null("FadeTransition")

func _ready() -> void:
	AudioManager.play_music( music )

	if complete_label:
		complete_label.visible = false


func _on_click_button_button_down() -> void:
	if finished:
		return

	if hammer_audio:
		hammer_audio.pitch_scale = randf_range(0.9, 1.1)
		hammer_audio.play()

	hits += amount_per_click
	emit_signal("hits_changed", hits)
	emit_signal("hits_clicked", amount_per_click)

	if hits >= hits_to_complete:
		complete_minigame()


func complete_minigame() -> void:
	if finished:
		return

	finished = true
	emit_signal("minigame_completed")

	PlayerStats.increase_stat("strength", 1)
	print("Strength increased to:", PlayerStats.get_stat("strength"))

	if click_button:
		click_button.set_disabled(true)

	if complete_label:
		complete_label.visible = true
		complete_label.text = "Complete!"
		complete_label.scale = Vector2(0.5, 0.5)

		var tween = get_tree().create_tween()
		tween.tween_property(complete_label, "scale", Vector2(1, 1), 0.2)

	if success_audio and success_sound:
		success_audio.stream = success_sound
		success_audio.play()

	await get_tree().create_timer(1.0).timeout

	if fade_transition:
		await fade_transition.fade_out()

	var return_scene = next_scene_path
	var return_target = target_transition_area

	if second_required_flag_name != "" and GameState.get_flag(second_required_flag_name):
		if second_alternate_next_scene_path != "":
			return_scene = second_alternate_next_scene_path
		if second_alternate_target_transition_area != "":
			return_target = second_alternate_target_transition_area
	elif required_flag_name != "" and GameState.get_flag(required_flag_name):
		if alternate_next_scene_path != "":
			return_scene = alternate_next_scene_path
		if alternate_target_transition_area != "":
			return_target = alternate_target_transition_area

	if return_scene != "":
		LevelManager.load_new_level(return_scene, return_target, Vector2.ZERO)
	else:
		push_error("No next scene path set for blacksmith minigame.")
