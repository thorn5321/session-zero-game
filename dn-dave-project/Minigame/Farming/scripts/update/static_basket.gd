extends Area2D

var base_scale := Vector2.ONE
var base_rotation := 0.0

func _ready() -> void:
	base_scale = scale
	base_rotation = rotation_degrees

func play_bounce() -> void:
	scale = base_scale
	rotation_degrees = base_rotation

	var tween := get_tree().create_tween()

	tween.tween_property(self, "scale", base_scale * Vector2(1.2, 0.8), 0.08)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	tween.tween_property(self, "scale", base_scale * Vector2(0.9, 1.1), 0.08)

	tween.tween_property(self, "scale", base_scale, 0.08)

	tween.tween_property(self, "rotation_degrees", base_rotation + 5, 0.05)
	tween.tween_property(self, "rotation_degrees", base_rotation - 5, 0.05)
	tween.tween_property(self, "rotation_degrees", base_rotation, 0.05)
