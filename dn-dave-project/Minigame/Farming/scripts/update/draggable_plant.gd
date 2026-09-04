extends Area2D

signal collected

@export var basket_path: NodePath
@export var sprout_texture: Texture2D
@export var grown_texture: Texture2D
@export var grown_scale_multiplier: float = 1.0
@export var hover_scale_multiplier: float = 1.05

var dragging := false
var start_position := Vector2.ZERO
var mouse_offset := Vector2.ZERO
var basket: Area2D
var is_grown := false
var sprite_base_scale := Vector2.ONE

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	start_position = global_position
	basket = get_node(basket_path) as Area2D
	input_pickable = true
	sprite_base_scale = sprite.scale

	if sprout_texture:
		sprite.texture = sprout_texture

	# Connect hover signals safely
	if not mouse_entered.is_connected(_on_mouse_entered):
		mouse_entered.connect(_on_mouse_entered)
	if not mouse_exited.is_connected(_on_mouse_exited):
		mouse_exited.connect(_on_mouse_exited)

func _input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			dragging = true
			mouse_offset = get_global_mouse_position() - global_position

			if not is_grown and grown_texture:
				sprite.texture = grown_texture
				is_grown = true
				sprite.scale = sprite_base_scale * grown_scale_multiplier

			play_click_tween()

		else:
			if dragging:
				dragging = false

				if overlaps_area(basket):
					basket.play_bounce()
					emit_signal("collected")
					queue_free()
				else:
					var tween := get_tree().create_tween()
					tween.tween_property(self, "global_position", start_position, 0.15)\
						.set_trans(Tween.TRANS_SINE)\
						.set_ease(Tween.EASE_OUT)

func _process(_delta: float) -> void:
	if dragging:
		global_position = get_global_mouse_position() - mouse_offset

func get_target_sprite_scale() -> Vector2:
	if is_grown:
		return sprite_base_scale * grown_scale_multiplier
	return sprite_base_scale

func play_click_tween() -> void:
	var target_scale := get_target_sprite_scale()
	sprite.scale = target_scale

	var tween := get_tree().create_tween()
	tween.tween_property(sprite, "scale", target_scale * Vector2(1.15, 0.9), 0.06)
	tween.tween_property(sprite, "scale", target_scale * Vector2(0.95, 1.08), 0.06)
	tween.tween_property(sprite, "scale", target_scale, 0.06)

func play_collect_tween() -> void:
	var tween := get_tree().create_tween()
	tween.parallel().tween_property(sprite, "scale", sprite.scale * 0.5, 0.08)
	tween.parallel().tween_property(self, "modulate:a", 0.0, 0.08)
	await tween.finished

func _on_mouse_entered() -> void:
	if dragging:
		return

	var target_scale := get_target_sprite_scale()
	sprite.scale = target_scale * hover_scale_multiplier

func _on_mouse_exited() -> void:
	if dragging:
		return

	sprite.scale = get_target_sprite_scale()
