extends Area2D

@export_enum("top", "middle", "bottom") var shelf_type: String = "top"



var occupied := false

var base_scale := Vector2.ONE
var base_rotation := 0.0

func _ready() -> void:
	base_scale = scale
	base_rotation = rotation_degrees

func play_bounce() -> void:
	scale = base_scale
	rotation_degrees = base_rotation

	var tween := get_tree().create_tween()
	tween.tween_property(self, "scale", base_scale * Vector2(1.1, 0.9), 0.06)
	tween.tween_property(self, "scale", base_scale, 0.06)
