extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	DiceManager.set_scene_nodes($CanvasLayer/Dice, $CanvasLayer/Dice/Label)
	print("Dice set in PlayGround scene")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
