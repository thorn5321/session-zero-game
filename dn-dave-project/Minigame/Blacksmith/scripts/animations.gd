extends MarginContainer

@onready var template: Label = $"../../Indicators/Template"
@onready var click_button: TextureButton = $CenterContainer/ClickButton
@onready var indicators: Control = $"../../Indicators"


func _ready() -> void:
	click_button.pivot_offset = click_button.size / 2

func _on_click_button_button_down() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(click_button, "scale", Vector2(.9, .9), .1)

func _on_click_button_button_up() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(click_button, "scale", Vector2(1, 1), .1)

func _on_game_hits_clicked(amount) -> void:
	var indicator = template.duplicate()
	indicator.text = "+" + str(amount)
	indicator.position = get_global_mouse_position()
	indicator.visible = true
	indicators.add_child(indicator)
	indicator.get_child(0).start()
