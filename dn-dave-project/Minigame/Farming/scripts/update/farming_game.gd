extends Control

var collected := 0
var finished := false

@export var music: AudioStream
@export var veggies_to_complete: int = 9
@export_file("*.tscn") var next_scene_path: String
@export var success_sound: AudioStream
@export var collect_sound: AudioStream
@export_file("*.tscn") var alternate_next_scene_path: String
@export var required_flag_name: String = ""
@export var alternate_target_transition_area: String = ""

@onready var success_audio: AudioStreamPlayer = get_node_or_null("CanvasLayer/SuccessAudio")
@onready var plant_audio: AudioStreamPlayer = get_node_or_null("CanvasLayer/PlantAudio")
@onready var complete_label: Label = get_node_or_null("CanvasLayer/CompleteLabel")
@onready var score_label: Label = get_node_or_null("CanvasLayer/ScoreLabel")
@onready var fade_transition = get_node_or_null("FadeTransition")
@onready var minigame_objects = get_node_or_null("CanvasLayer/Minigame_Objects")
@export var target_transition_area: String = "LevelTransition"

func _ready() -> void:
	if music:
		AudioManager.play_music(music)

	if complete_label:
		complete_label.visible = false
		complete_label.mouse_filter = Control.MOUSE_FILTER_IGNORE

	if score_label:
		score_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		update_score_label()

	connect_veggies()

func connect_veggies() -> void:
	if minigame_objects == null:
		push_error("Minigame_Objects node not found.")
		return

	for child in minigame_objects.get_children():
		if child.has_signal("collected"):
			if not child.collected.is_connected(_on_veggie_collected):
				child.collected.connect(_on_veggie_collected)

func _on_veggie_collected() -> void:
	if finished:
		return

	collected += 1
	update_score_label()

	if plant_audio and collect_sound:
		plant_audio.stream = collect_sound
		plant_audio.pitch_scale = randf_range(0.95, 1.05)
		plant_audio.play()

	if collected >= veggies_to_complete:
		complete_minigame()

func update_score_label() -> void:
	if score_label:
		score_label.text = "Collected: %d / %d" % [collected, veggies_to_complete]

func complete_minigame() -> void:
	if finished:
		return

	finished = true
	
	PlayerStats.increase_stat("wisdom", 1)
	print("Wisdom increased to:", PlayerStats.get_stat("wisdom"))

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

	if required_flag_name != "" and GameState.get_flag(required_flag_name):
		if alternate_next_scene_path != "":
			return_scene = alternate_next_scene_path
		if alternate_target_transition_area != "":
			return_target = alternate_target_transition_area

	if return_scene != "":
		LevelManager.load_new_level(return_scene, return_target, Vector2.ZERO)
	else:
		push_error("No next scene path set for potion minigame.")
