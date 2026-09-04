extends Node2D

var is_ready = false

# 🎯 Potion type (dropdown in inspector)
@export_enum("potion_large", "potion_medium", "potion_small")
var ingredient_type: String:
	set(value):
		ingredient_type = value
		if is_ready:
			update_sprite()

@onready var sprite: Sprite2D = $Sprite2D

var draggable = false
var is_inside_dropable = false
var body_ref = null
var offset: Vector2
var initialPos: Vector2

# 🧃 Potion textures
var textures = {
	"potion_large": preload("res://Minigame/Potion/Assets/Potion small.PNG"),
	"potion_medium": preload("res://Minigame/Potion/Assets/Potion medium.PNG"),
	"potion_small": preload("res://Minigame/Potion/Assets/potion_large.PNG")
}

func _ready():
	is_ready = true
	update_sprite()

# 🎨 Update sprite based on type
func update_sprite():
	if sprite == null:
		return

	if ingredient_type in textures:
		sprite.texture = textures[ingredient_type]

func _process(_delta):
	if draggable: 
		if Input.is_action_just_pressed("click"):
			initialPos = global_position
			offset = get_global_mouse_position() - global_position
			global.is_dragging = true

		if Input.is_action_pressed("click"):
			global_position = get_global_mouse_position() - offset

		elif Input.is_action_just_released("click"):
			global.is_dragging = false
			var tween = get_tree().create_tween()

			if is_inside_dropable and body_ref != null:

				# ✅ CORRECT DROP
				if ingredient_type == body_ref.potion_type:
					print("✅ Correct!")

					tween.tween_property(self, "position", body_ref.position, 0.2)
					await tween.finished

					global.score += 1

					# 🧃 LOCK potion in place (DO NOT DELETE)
					draggable = false
					set_process(false)
					set_physics_process(false)
					$Area2D.monitoring = false

				# ❌ WRONG DROP
				else:
					print("❌ Wrong!")
					tween.tween_property(self, "global_position", initialPos, 0.2)

			else:
				tween.tween_property(self, "global_position", initialPos, 0.2)


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
		body_ref = body

		# 🎨 preview correct / incorrect
		if ingredient_type == body.potion_type:
			body.modulate = Color.GREEN
		else:
			body.modulate = Color.RED


func _on_area_2d_body_exited(body):
	if body.is_in_group("droppable"):
		is_inside_dropable = false
		body.modulate = Color(Color.MEDIUM_PURPLE, 0.7)
