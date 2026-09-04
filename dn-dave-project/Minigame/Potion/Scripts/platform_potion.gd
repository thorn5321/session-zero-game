extends StaticBody2D

@export_enum("potion_large", "potion_medium", "potion_small")
var potion_type: String  # what this platform accepts

func _ready():
	update_visual()

func _process(_delta):
	visible = global.is_dragging


func update_visual():
	# 🎨 Give each platform a distinct color so player knows where to sort
	match potion_type:
		"potion_large":
			modulate = Color(0.8, 0.4, 0.4, 0.7)   # reddish
		"potion_medium":
			modulate = Color(0.4, 0.8, 0.4, 0.7)   # greenish
		"potion_small":
			modulate = Color(0.4, 0.4, 0.8, 0.7)   # bluish
