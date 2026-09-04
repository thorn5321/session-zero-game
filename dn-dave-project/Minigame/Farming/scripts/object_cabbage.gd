extends Area2D

var draggable = false
var is_inside_dropable = false
var body_ref
var offset: Vector2
var initialPos: Vector2

@onready var sprite = $Sprite2D

var seed_texture = preload("res://Minigame/Farming/Assets/cabbage.png")
var plant_texture = preload("res://Minigame/Farming/Assets/cabbage_leafy.png")
var is_grown = false

func _process(_delta):
	if draggable:
		if Input.is_action_just_pressed("click"):
			initialPos = global_position
			offset = get_global_mouse_position() - global_position
			global.is_dragging = true

			if not is_grown:
				sprite.texture = plant_texture
				is_grown = true

				var grow_tween = get_tree().create_tween()
				scale = Vector2(1, 1)
				grow_tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.1)
				grow_tween.tween_property(self, "scale", Vector2(1, 1), 0.1)

		if Input.is_action_pressed("click"):
			global_position = get_global_mouse_position() - offset

		elif Input.is_action_just_released("click"):
			global.is_dragging = false

			if is_inside_dropable:
				visible = false
				# queue_free()
				global.score += 1
			else:
				var tween = get_tree().create_tween()
				tween.tween_property(self, "global_position", initialPos, 0.2).set_ease(Tween.EASE_OUT)

func _on_area_2d_mouse_entered():
	if not global.is_dragging:
		draggable = true
		scale = Vector2(1.05, 1.05)

func _on_area_2d_mouse_exited():
	if not global.is_dragging:
		draggable = false
		scale = Vector2(1, 1)

func _on_area_2d_body_entered(body: StaticBody2D):
	if body.is_in_group("droppable"):
		is_inside_dropable = true
		body.modulate = Color(Color.REBECCA_PURPLE, 1)
		body_ref = body

func _on_area_2d_body_exited(body):
	if body.is_in_group("droppable"):
		is_inside_dropable = false
		body.modulate = Color(1, 1, 1, 1)
