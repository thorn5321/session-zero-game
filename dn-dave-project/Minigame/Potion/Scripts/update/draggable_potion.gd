extends Area2D

signal placed_correctly

@export_enum("top", "middle", "bottom") var potion_type: String = "top"

var dragging := false
var placed := false
var start_position := Vector2.ZERO
var mouse_offset := Vector2.ZERO
var sprite_base_scale := Vector2.ONE

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	start_position = global_position
	input_pickable = true
	sprite_base_scale = sprite.scale

	if not mouse_entered.is_connected(_on_mouse_entered):
		mouse_entered.connect(_on_mouse_entered)
	if not mouse_exited.is_connected(_on_mouse_exited):
		mouse_exited.connect(_on_mouse_exited)

func _input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if placed:
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			dragging = true
			mouse_offset = get_global_mouse_position() - global_position
			play_click_tween()
		else:
			if dragging:
				dragging = false
				try_place_in_matching_zone()

func _process(_delta: float) -> void:
	if dragging and not placed:
		global_position = get_global_mouse_position() - mouse_offset

func try_place_in_matching_zone() -> void:
	var overlapping_areas = get_overlapping_areas()

	for area in overlapping_areas:
		if area.get("shelf_type") == potion_type and not area.get("occupied"):
			place_in_zone(area)
			return

	reset_position()

	reset_position()

func place_in_zone(zone: Area2D) -> void:
	placed = true
	zone.occupied = true
	global_position = zone.global_position

	if zone.has_method("play_bounce"):
		zone.play_bounce()

	emit_signal("placed_correctly")

func reset_position() -> void:
	var tween := get_tree().create_tween()
	tween.tween_property(self, "global_position", start_position, 0.15)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)

func play_click_tween() -> void:
	sprite.scale = sprite_base_scale

	var tween := get_tree().create_tween()
	tween.tween_property(sprite, "scale", sprite_base_scale * Vector2(1.12, 0.92), 0.06)
	tween.tween_property(sprite, "scale", sprite_base_scale * Vector2(0.96, 1.06), 0.06)
	tween.tween_property(sprite, "scale", sprite_base_scale, 0.06)

func _on_mouse_entered() -> void:
	if dragging or placed:
		return
	sprite.scale = sprite_base_scale * 1.05

func _on_mouse_exited() -> void:
	if dragging or placed:
		return
	sprite.scale = sprite_base_scale
