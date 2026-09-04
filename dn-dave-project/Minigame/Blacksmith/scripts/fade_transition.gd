extends CanvasLayer

@onready var color_rect: ColorRect = $Control/ColorRect
@onready var animation_player: AnimationPlayer = $Control/AnimationPlayer
@onready var anim = $Control/AnimationPlayer

func _ready() -> void:
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE

func fade_out() -> void:
	animation_player.play("fade_out")
	await animation_player.animation_finished

func fade_in() -> void:
	animation_player.play("fade_in")
	await animation_player.animation_finished
	
	
