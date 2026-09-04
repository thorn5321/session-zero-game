extends Control

var placed := 0
var finished := false

@export var music: AudioStream
@export var potions_to_complete: int = 11
@export_file("*.tscn") var next_scene_path: String
@export var success_sound: AudioStream
@export var collect_sound: AudioStream

@onready var success_audio: AudioStreamPlayer = get_node_or_null("CanvasLayer/SuccessAudio")
@onready var potion_audio: AudioStreamPlayer = get_node_or_null("CanvasLayer/PlantAudio")
@onready var complete_label: Label = get_node_or_null("CanvasLayer/CompleteLabel")
@onready var score_label: Label = get_node_or_null("CanvasLayer/ScoreLabel")
@onready var fade_transition = get_node_or_null("FadeTransition")
@export var target_transition_area: String = "LevelTransition"
@export_file("*.tscn") var alternate_next_scene_path: String
@export var required_flag_name: String = ""
@export var alternate_target_transition_area: String = ""

@export_file("*.tscn") var second_alternate_next_scene_path: String
@export var second_required_flag_name: String = ""
@export var second_alternate_target_transition_area: String = ""

func _ready() -> void:
	if music:
		AudioManager.play_music(music)

	if complete_label:
		complete_label.visible = false
		complete_label.mouse_filter = Control.MOUSE_FILTER_IGNORE

	if score_label:
		score_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		update_score_label()

	for potion in get_tree().get_nodes_in_group("potion_object"):
		if potion.has_signal("placed_correctly"):
			if not potion.placed_correctly.is_connected(_on_potion_placed):
				potion.placed_correctly.connect(_on_potion_placed)

func _on_potion_placed() -> void:
	if finished:
		return


	placed += 1
	update_score_label()

	if potion_audio and collect_sound:
		potion_audio.stream = collect_sound
		potion_audio.pitch_scale = randf_range(0.95, 1.05)
		potion_audio.play()

	if placed >= potions_to_complete:
		complete_minigame()

func update_score_label() -> void:
	if score_label:
		score_label.text = "Placed: %d / %d" % [placed, potions_to_complete]

func complete_minigame() -> void:
	if finished:
		return

	finished = true

	PlayerStats.increase_stat("intelligence", 1)
	print("Intelligence increased to:", PlayerStats.get_stat("intelligence"))

	if complete_label:
		complete_label.visible = true
		complete_label.text = "Complete!"
		complete_label.scale = Vector2(0.5, 0.5)

		var tween := get_tree().create_tween()
		tween.tween_property(complete_label, "scale", Vector2(1, 1), 0.2)\
			.set_trans(Tween.TRANS_BACK)\
			.set_ease(Tween.EASE_OUT)

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
		push_error("No next scene path set for potion minigame.")
